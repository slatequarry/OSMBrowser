unit uOSM;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  IdHTTPHeaderInfo, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  StrUtils, Xml.XMLIntf, Xml.XMLDoc, Math,
  Vcl.Graphics, Vcl.Imaging.pngimage, Vcl.Imaging.Jpeg;

type
  TTileKey = record
    z,x,y  :integer;
    constructor Create(aZ,aX,aY :integer);
  end;

type
  TOsm = class;

  TTile = class(TObject)
  private
    FOsm      :TOsm;
    FKey      :TTileKey;
    FUrl      :string;
    FLoaded   :boolean;
    FError    :boolean;
    FErrorMsg :string;
    FBitmap   :TBitmap;
    FThread   :TThread;
    function getBitmap :TBitmap;
  public
    constructor Create(aOsm :TOsm; aKey :TTileKey; aUrl :string);
    destructor Destroy;
    property Key :TTileKey read FKey;
    property Url :string read FUrl;
    property Loaded :boolean read FLoaded;
    property Error :boolean read FError;
    property ErrorMsg :string read FErrorMsg;
    property Bitmap :TBitmap read getBitmap;
  end;

  TTileLoadedEvent = procedure(Tile: TTile) of object;

  TOsm = class(TObject)
  private
    FTileUrl      :string;
    FOnTileLoaded :TTileLoadedEvent;
    FProxyParams  :TIdProxyConnectionInfo;
    FTiles        :TDictionary<TTileKey,TTile>;
    procedure TileLoaded(aTile :TTile);
    procedure setTileUrl(aTileUrl :string);
    procedure clearTiles;
  public
    property TileUrl :string read FTileUrl write setTileUrl;
    property ProxyParams :TIdProxyConnectionInfo read FProxyParams;
    property OnTileLoaded :TTileLoadedEvent read FOnTileLoaded write FOnTileLoaded;
    constructor Create;
    function getTile(zoom, xtile, ytile :integer) :TTile;
    procedure CoordToTile(lat_deg, lon_deg :double; zoom :integer; var xtile, ytile :double);
    procedure TileToCoord(xtile, ytile :double; zoom :integer; var lat_deg, lon_deg :double);
    function Search(text :string; var lat,lon :double) :boolean;
  end;

implementation

constructor TTileKey.Create(aZ,aX,aY :integer);
begin
  z:=aZ; x:=aX; y:=aY;
end;

constructor TTile.Create(aOsm :TOsm; aKey :TTileKey; aUrl :string);
begin
  FOsm:=aOsm;
  FKey:=aKey;
  FUrl:=aUrl;
  FLoaded:=false;
  FError:=false;
  FBitmap:=nil;
  FThread:=TThread.CreateAnonymousThread(procedure
    var http    :TidHttp;
        stream  :TMemoryStream;
        img     :TGraphic;
        msg     :string;
    begin
      try
        http:=TidHttp.Create(nil);
        http.ProxyParams.Assign(FOsm.FProxyParams);
        try
          stream:=TMemoryStream.Create;
          try
            http.Get(FUrl,stream);
            stream.Position:=0;
            if EndsText('.png',FUrl) then
              img:=TPngImage.Create
            else
              img:=TJpegImage.Create;
            try
              img.LoadFromStream(stream);
              TThread.Synchronize(nil, procedure
                begin
                  FBitmap:=TBitmap.Create;
                  FBitmap.Assign(img);
                  FLoaded:=true;
                  FError:=false;
                end);
            finally
              FreeAndNil(img);
            end;
          finally
            FreeAndNil(stream);
          end;
        finally
          FreeAndNil(http);
        end;
      except
        on e: Exception do begin
          msg:=e.Message;
          TThread.Synchronize(nil, procedure
            begin
              FBitmap:=nil;
              FLoaded:=false;
              FError:=true;
              FErrorMsg:=msg;
            end);
        end;
      end;
      TThread.Synchronize(nil, procedure
        begin
          aOsm.TileLoaded(self);
        end);
    end);
  FThread.FreeOnTerminate:=true;
  FThread.Start;
end;

destructor TTile.Destroy;
begin
  if assigned(FBitmap) then
    FBitmap.Free;
end;

function TTile.getBitmap: TBitmap;
begin
  if FLoaded then
    result:=FBitmap
  else
    result:=nil;
end;

constructor TOsm.Create;
begin
  FProxyParams:=TIdProxyConnectionInfo.Create;
  FTiles:=TDictionary<TTileKey,TTile>.Create;
end;

function TOsm.getTile(zoom, xtile, ytile :integer) :TTile;
var key  :TTileKey;
    url  :string;
    tile :TTile;
begin
  key:=TTileKey.Create(zoom,xtile,ytile);
  if not FTiles.TryGetValue(key,tile) then begin
    url:=FTileUrl;
    url:=ReplaceStr(url,'${z}',IntToStr(zoom));
    url:=ReplaceStr(url,'${x}',IntToStr(xtile));
    url:=ReplaceStr(url,'${y}',IntToStr(ytile));
    tile:=TTile.Create(self,key,url);
    FTiles.Add(key,tile);
  end;
  result:=tile;
end;

procedure TOsm.clearTiles;
var item: TPair<TTileKey, TTile>;
begin
  for item in FTiles do
    item.Value.Free;
  FTiles.Clear;
end;

procedure TOsm.CoordToTile(lat_deg, lon_deg :double; zoom :integer; var xtile, ytile :double);
var lat_rad, n: Double;
begin
  lat_rad := DegToRad(lat_deg);
  n := Power(2, zoom);
  xtile := ((lon_deg + 180) / 360) * n;
  ytile := (1 - (ln(Tan(lat_rad) + (1 /Cos(lat_rad))) / Pi)) / 2 * n;
end;

procedure TOsm.TileToCoord(xtile, ytile :double; zoom :integer; var lat_deg, lon_deg :double);
var lat_rad, n: Real;
begin
  n := Power(2, zoom);
  lat_rad := Arctan (Sinh (Pi * (1 - 2 * ytile / n)));
  lat_deg := RadtoDeg (lat_rad);
  lon_deg := xtile / n * 360.0 - 180.0;
end;

function TOsm.Search(text :string; var lat,lon :double) :boolean;
var xml     :string;
    http    :TidHttp;
    doc     :IXMLDocument;
    place   :IXMLNode;
    fs      :TFormatSettings;
begin
//  try
    http := TidHttp.Create(nil);
    http.ProxyParams.Assign(ProxyParams);
    try
      http.Request.UserAgent:='Delphi OSM Browser';
      xml := http.Get('http://nominatim.openstreetmap.org/search?format=xml&q='+ReplaceStr(text,' ','+'));
      doc := TXMLDocument.Create(nil);
      doc.LoadFromXML(xml);
      place:=doc.DocumentElement.ChildNodes[0];
      fs:=TFormatSettings.Create;
      fs.DecimalSeparator:='.';
      lat:=StrToFloat(place.Attributes['lat'],fs);
      lon:=StrToFloat(place.Attributes['lon'],fs);
      result:=True;
    finally
      FreeAndNil(http);
    end;
//  except
//    result:=false;
//  end;
end;

procedure TOsm.setTileUrl(aTileUrl: string);
begin
  if FTileUrl<>aTileUrl then begin
    FTileUrl:=aTileUrl;
    clearTiles;
  end;
end;

procedure TOsm.TileLoaded(aTile: TTile);
begin
  if assigned(FOnTileLoaded) then
    FOnTileLoaded(aTile);
end;

end.
