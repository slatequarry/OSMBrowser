unit uOSMBrowser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  JvComponentBase, JvAppStorage, JvAppIniStorage, Vcl.Menus, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.ComCtrls, uOSM,
  JvExControls, JvxSlider, System.StrUtils;

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
  private
    FValid       :boolean;
    FLat,FLon    :double;
    FZoom        :integer;
    xtile, ytile :integer;
    tiles        :array of array of TTile;
    osm          :tOSM;
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
  loadConfig(true);
end;

procedure TfrmOSMbrowser.FormResize(Sender: TObject);
begin
  refresh;
end;

procedure TfrmOSMbrowser.mnuConfigClick(Sender: TObject);
begin
  if TfrmConfig.showDialog(JvAppIni) then
    loadConfig;
end;

procedure TfrmOSMbrowser.mnuQuitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmOSMbrowser.PaintBoxPaint(Sender: TObject);
var x,y  :integer;
    tile :TTile;
    bmp  :TBitmap;
    r    :TRect;
begin
  if FValid then begin
    for x:=Low(tiles) to High(tiles) do
      for y:=Low(tiles[x]) to High(tiles[x]) do begin
        tile:=tiles[x,y];
        r:=Rect(x*256,y*256,(x+1)*256,(y+1)*256);
        if tile.Loaded then begin
          bmp:=tile.Bitmap;
          PaintBox.Canvas.Draw(x*256,y*256,bmp);
//          PaintBox.Canvas.TextOut(x*256+10,y*256+10,IntToStr(bmp.Width)+'*'+IntToStr(bmp.Height));
        end else begin
          PaintBox.Canvas.FillRect(r);
          PaintBox.Canvas.TextRect(r,x*256+10,y*256+10,IfThen(tile.Error,'Fehler !','Lade ...'));
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
  FValid:=osm.Search(text,FLat,FLon);
  refresh;
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
var xcount,ycount :integer;
    x,y     :integer;
begin
  if FValid then begin
    osm.CoordsToTile(FLat,FLon,FZoom,xtile,ytile);
    Memo.Lines.Add('lat/lon = '+FloatToStr(FLat) + ' / ' + FloatToStr(FLon));
    Memo.Lines.Add('xtile/ytile = '+IntToStr(xtile) + ' / ' + IntToStr(ytile));

    xcount:=PaintBox.Width div 256 + 1;
    ycount:=PaintBox.Height div 256 + 1;
//    xcount:=1;
//    ycount:=1;
    setLength(tiles,xcount);
    for x:=0 to xcount-1 do begin
      setLength(tiles[x],ycount);
      for y:=0 to ycount-1 do
        tiles[x,y]:=osm.getTile(FZoom,xtile-xcount div 2+x,ytile-ycount div 2+y);
    end;
  end;
  PaintBox.Invalidate;
  slZoom.Invalidate;
end;

end.
