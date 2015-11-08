unit uOSMBrowser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  JvComponentBase, JvAppStorage, JvAppIniStorage, Vcl.Menus, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.ComCtrls, uOSM;

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
    procedure btnSearchClick(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure mnuQuitClick(Sender: TObject);
    procedure mnuConfigClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    lat,lon      :double;
    zoom         :integer;
    xtile, ytile :integer;
    tiles        :array of array of TBitmap;
    osm          :tOSM;
    procedure loadConfig(start :boolean = false);
    procedure search(text :string);
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
  osm:=tOSM.Create;
  loadConfig(true);

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
var x,y :integer;
begin
  for x:=Low(tiles) to High(tiles) do
    for y:=Low(tiles[x]) to High(tiles[x]) do
      PaintBox.Canvas.Draw(x*256,y*256,tiles[x,y]);
end;

procedure TfrmOSMbrowser.btnSearchClick(Sender: TObject);
begin
  search(edtSearch.Text);
end;

procedure TfrmOSMbrowser.loadConfig(start :boolean = false);
var s  :string;
begin
  osm.ProxyParams.BasicAuthentication:=JvAppIni.ReadBoolean('Proxy\BasicAuth',false);
  osm.ProxyParams.ProxyServer:=JvAppIni.ReadString('Proxy\Server','');
  osm.ProxyParams.ProxyPort:=JvAppIni.ReadInteger('Proxy\Port',0);
  osm.ProxyParams.ProxyUsername:=JvAppIni.ReadString('Proxy\User','');
  osm.ProxyParams.ProxyPassword:=JvAppIni.ReadString('Proxy\Password','');
  if start then begin
    s:=JvAppIni.ReadString('Search\Start','');
    if s<>'' then begin
      edtSearch.Text:=s;
      search(s);
    end;
  end;
end;

procedure TfrmOSMbrowser.search(text :string);
var xcount,ycount :integer;
    x,y     :integer;
begin
  if osm.Search(text,lat,lon) then begin
    zoom:=14;
    osm.CoordsToTile(lat,lon,zoom,xtile,ytile);
    Memo.Lines.Add('lat/lon = '+FloatToStr(lat) + ' / ' + FloatToStr(lon));
    Memo.Lines.Add('xtile/ytile = '+IntToStr(xtile) + ' / ' + IntToStr(ytile));

    xcount:=PaintBox.Width div 256 + 1;
    ycount:=PaintBox.Height div 256 + 1;
    setLength(tiles,xcount);
    for x:=0 to xcount-1 do begin
      setLength(tiles[x],ycount);
      for y:=0 to ycount-1 do
        tiles[x,y]:=osm.getTile(zoom,xtile-xcount div 2+x,ytile-ycount div 2+y);
    end;
  end;
  PaintBox.Invalidate;
end;

procedure TfrmOSMbrowser.refresh;
begin

end;

end.
