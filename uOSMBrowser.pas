unit uOSMBrowser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Math,
  JvComponentBase, JvAppStorage, JvAppIniStorage, Vcl.Menus, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.ComCtrls, uOSM,
  JvExControls, JvxSlider, System.StrUtils, System.IOUtils;

type
  TfrmOSMbrowser = class(TForm)
    IdHTTP: TIdHTTP;
    pnlSearch: TPanel;
    btnSearch: TButton;
    edtSearch: TEdit;
    PageControl: TPageControl;
    tabKarte: TTabSheet;
    tabMemo: TTabSheet;
    PaintBox: TPaintBox;
    Memo: TMemo;
    MainMenu: TMainMenu;
    mnuConfig: TMenuItem;
    mnuQuit: TMenuItem;
    JvAppIni: TJvAppIniFileStorage;
    slZoom: TJvxSlider;
    procedure btnSearchClick(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure mnuQuitClick(Sender: TObject);
    procedure mnuConfigClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure slZoomChange(Sender: TObject);
    procedure TileLoaded(Tile: TTile);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxDblClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    moveing        :boolean;
    xs,ys          :integer;
    xst,yst        :double;

    FValid         :boolean;
    FLat,FLon      :double;
    FZoom          :integer;
    FXTile, FYTile :double;

    xo,yo          :integer;
    tiles          :array of array of TTile;

    osm            :tOSM;
    procedure loadConfig(start :boolean = false);
    procedure search(text :string);
    procedure setZoom(aZoom :integer);
    procedure refresh;
  public
    { Public-Deklarationen }
  end;

var
  frmOSMbrowser: TfrmOSMbrowser;

implementation

{$R *.dfm}

uses uConfigDialog;

procedure TfrmOSMbrowser.FormCreate(Sender: TObject);
begin
  PaintBox.ControlStyle := PaintBox.ControlStyle + [csopaque];

  FValid:=false;
  FZoom:=1;
  FLat:=0; FLon:=0;
  osm:=tOSM.Create;
  osm.OnTileLoaded:=TileLoaded;

  if not TFile.Exists(JvAppIni.FullFileName) then
    TfrmConfig.showDialog(JvAppIni,false);
  loadConfig(true);
end;

procedure TfrmOSMbrowser.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:=true;
  slZoom.Value:=slZoom.Value+IfThen(WheelDelta>0,1,-1);
end;

procedure TfrmOSMbrowser.FormResize(Sender: TObject);
begin
  refresh;
end;

procedure TfrmOSMbrowser.mnuConfigClick(Sender: TObject);
begin
  if TfrmConfig.showDialog(JvAppIni) then begin
    loadConfig;
    refresh;
  end;
end;

procedure TfrmOSMbrowser.mnuQuitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmOSMbrowser.PaintBoxDblClick(Sender: TObject);
var mp :TPoint;
begin
  GetCursorPos(mp);
  mp:=PaintBox.ScreenToClient(mp);
  osm.TileToCoord(
    FXTile-(PaintBox.Width div 2-mp.X)/256,
    FYTile-(PaintBox.Height div 2-mp.Y)/256,
    FZoom,FLat,FLon);
  slZoom.Value:=slZoom.Value+1;
end;

procedure TfrmOSMbrowser.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then begin
    moveing:=true;
    xs:=X; ys:=Y;
    xst:=FXTile; yst:=FYTile;
  end;
end;

procedure TfrmOSMbrowser.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var xm,ym  :integer;
    xt,yt  :double;
begin
  if moveing then begin
    xm:=xs-X; ym:=ys-Y;
    xt:=xst+xm/256; yt:=yst+ym/256;
    osm.TileToCoord(xt,yt,FZoom,FLat,FLon);
    refresh;
  end;
end;

procedure TfrmOSMbrowser.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if moveing then begin
    moveing:=false;
    PaintBox.Invalidate;
  end;
end;

procedure TfrmOSMbrowser.PaintBoxPaint(Sender: TObject);
var x,y   :integer;
    xp,yp :integer;
    tile  :TTile;
    bmp   :TBitmap;
    r     :TRect;
begin
  if FValid then begin
    for x:=Low(tiles) to High(tiles) do
      for y:=Low(tiles[x]) to High(tiles[x]) do begin
        tile:=tiles[x,y];
        xp:=x*256+xo; yp:=y*256+yo;
        r:=Rect(xp,yp,xp+256,yp+256);
        if tile.Loaded then begin
          bmp:=tile.Bitmap;
          PaintBox.Canvas.Draw(xp,yp,bmp);
        end else begin
          PaintBox.Canvas.FillRect(r);
          if tile.Error then begin
            PaintBox.Canvas.TextOut(xp+10,yp+10,'Fehler !');
            PaintBox.Canvas.TextOut(xp+10,yp+30,tile.ErrorMsg);
          end else begin
            PaintBox.Canvas.TextOut(xp+10,yp+10,'Lade ...');
            PaintBox.Canvas.TextOut(xp+10,yp+30,tile.Url);
          end;
        end;
      end;
  end else begin
    PaintBox.Canvas.FillRect(Rect(0,0,PaintBox.Width-1,PaintBox.Height-1));
  end;
end;

procedure TfrmOSMbrowser.btnSearchClick(Sender: TObject);
begin
  search(edtSearch.Text);
end;

procedure TfrmOSMbrowser.loadConfig(start :boolean = false);
var s  :string;
    z  :integer;
begin
  osm.TileUrl:=JvAppIni.ReadString('Server\TileUrl','');
  osm.ProxyParams.BasicAuthentication:=JvAppIni.ReadBoolean('Proxy\BasicAuth',false);
  osm.ProxyParams.ProxyServer:=JvAppIni.ReadString('Proxy\Server','');
  osm.ProxyParams.ProxyPort:=JvAppIni.ReadInteger('Proxy\Port',0);
  osm.ProxyParams.ProxyUsername:=JvAppIni.ReadString('Proxy\User','');
  osm.ProxyParams.ProxyPassword:=JvAppIni.ReadString('Proxy\Password','');
  if start then begin
    z:=JvAppIni.ReadInteger('Start\Zoom',1);
    setZoom(z);

    s:=JvAppIni.ReadString('Start\Search','');
    if s<>'' then begin
      edtSearch.Text:=s;
      search(s);
    end;
  end;
end;

procedure TfrmOSMbrowser.search(text :string);
begin
  if osm.Search(text,FLat,FLon) then begin
    FValid:=true;
    refresh;
  end else
    ShowMessage('Nicht''s gefunden :(');
end;

procedure TfrmOSMbrowser.setZoom(aZoom :integer);
begin
  if (aZoom>=1)and(aZoom<=19)and(aZoom<>FZoom) then begin
    FZoom:=aZoom;
    slZoom.Value:=FZoom;
    refresh;
  end;
end;

procedure TfrmOSMbrowser.slZoomChange(Sender: TObject);
begin
  setZoom(slZoom.Value);
end;

procedure TfrmOSMbrowser.TileLoaded(Tile: TTile);
begin
  PaintBox.Invalidate;
  slZoom.Invalidate;
end;

procedure TfrmOSMbrowser.refresh;
var x,y,xc,yc :integer;
    w,h,x0,y0 :double;
begin
  if FValid then begin
    osm.CoordToTile(FLat,FLon,FZoom,FXTile,FYTile);

    w:=PaintBox.Width/256; h:=PaintBox.Height/256;
    xc:=trunc(w)+2; yc:=trunc(h)+2;

    x0:=FXTile-w/2; y0:=FYTile-h/2;
    xo:=-round(frac(x0)*256); yo:=-round(frac(y0)*256);

    Memo.Clear;
    Memo.Lines.Add('lat/lon = '+ FloatToStr(FLat) + ' / ' + FloatToStr(FLon));
    Memo.Lines.Add('xtile/ytile = '+ FloatToStr(FXTile) + ' / ' + FloatToStr(FYTile));
    Memo.Lines.Add('size(pixels) = '+ IntToStr(PaintBox.Width) + ' / ' + IntToStr(PaintBox.Height));
    Memo.Lines.Add('size(tiles) = '+ FloatToStr(w) + ' / ' + FloatToStr(h));
    Memo.Lines.Add('size of tiles array = '+ FloatToStr(xc) + ' / ' + FloatToStr(yc));
    Memo.Lines.Add('upper left(tiles) = '+ FloatToStr(x0) + ' / ' + FloatToStr(y0));
    Memo.Lines.Add('offset(pixels) = '+ FloatToStr(xo) + ' / ' + FloatToStr(yo));

    for x:=xc to High(tiles) do
      setLength(tiles[x],0);

    setLength(tiles,xc);
    for x:=0 to xc-1 do begin
      setLength(tiles[x],yc);
      for y:=0 to yc-1 do
        tiles[x,y]:=osm.getTile(FZoom,trunc(x0)+x,trunc(y0)+y);
    end;
  end;
  PaintBox.Invalidate;
  slZoom.Invalidate;
end;

end.
