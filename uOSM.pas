unit uOSM;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  IdHTTPHeaderInfo, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  StrUtils, Xml.XMLIntf, Xml.XMLDoc, Math,
  Vcl.Graphics, Vcl.Imaging.pngimage;

type
  TTileKey = record
    z,x,y  :integer;
    constructor Create(aZ,aX,aY :integer);
  end;

type
  TOsm = class;

  TTile = class(TObject)
  private
    FOsm     :TOsm;
    FKey     :TTileKey;
    FUrl     :string;
    FLoaded  :boolean;
    FError   :boolean;
    FBitmap  :TBitmap;
    FThread  :TThread;
    function getBitmap :TBitmap;
  public
    constructor Create(aOsm :TOsm; aKey :TTileKey; aUrl :string);
    property Key :TTileKey read FKey;
    property Loaded :boolean read FLoaded;
    property Error :boolean read FError;
    property Bitmap :TBitmap read getBitmap;
  end;

  TTileLoadedEvent = procedure(Tile: TTile) of object;

  TOsm = class(TObject)
  private
    FOnTileLoaded :TTileLoadedEvent;
    FProxyParams  :TIdProxyConnectionInfo;
    FTiles        :TDictionary<TTileKey,TTile>;
    procedure TileLoaded(aTile :TTile);
  public
    property ProxyParams :TIdProxyConnectionInfo read FProxyParams;
    property OnTileLoaded :TTileLoadedEvent read FOnTileLoaded write FOnTileLoaded;
    constructor Create;
    function getTile(zoom, xtile, ytile :integer) :TTile;
    procedure CoordsToTile(lat_deg, lon_deg :double; zoom :integer; var xtile, ytile :integer);
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
        png     :TPngImage;
    begin
      try
        http:=TidHttp.Create(nil);
        http.ProxyParams.Assign(FOsm.FProxyParams);
        try
          stream:=TMemoryStream.Create;
          try
            http.Get(FUrl,stream);
            stream.Position:=0;
            png:=TPngImage.Create;
            try
              png.LoadFromStream(stream);
              TThread.Synchronize(nil, procedure
                begin
                  FBitmap:=TBitmap.Create;
                  FBitmap.Assign(png);
                  FLoaded:=true;
                  FError:=false;
                end);
            finally
              FreeAndNil(png);
            end;
          finally
            FreeAndNil(stream);
          end;
        finally
          FreeAndNil(http);
        end;
      except
        TThread.Synchronize(nil, procedure
          begin
            FBitmap:=nil;
            FLoaded:=false;
            FError:=true;
          end);
      end;
      TThread.Synchronize(nil, procedure
        begin
          aOsm.TileLoaded(self);
        end);
    end);
  FThread.FreeOnTerminate:=true;
  FThread.Start;
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
    url:='http://a.tile.openstreetmap.org/${z}/${x}/${y}.png';
//    url:='http://otile1.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png';
//    url:='http://a.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png';
    url:=ReplaceStr(url,'${z}',IntToStr(zoom));
    url:=ReplaceStr(url,'${x}',IntToStr(xtile));
    url:=ReplaceStr(url,'${y}',IntToStr(ytile));
    tile:=TTile.Create(self,key,url);
    FTiles.Add(key,tile);
  end;
  result:=tile;
end;

procedure TOsm.CoordsToTile(lat_deg, lon_deg :double; zoom :integer; var xtile, ytile :integer);
var lat_rad, n: Real;
begin
  lat_rad := DegToRad(lat_deg);
  n := Power(2, zoom);
  xtile := Trunc(((lon_deg + 180) / 360) * n);
  ytile := Trunc((1 - (ln(Tan(lat_rad) + (1 /Cos(lat_rad))) / Pi)) / 2 * n);
end;

function TOsm.Search(text :string; var lat,lon :double) :boolean;
var xml     :string;
    http    :TidHttp;
    doc     :IXMLDocument;
    place   :IXMLNode;
begin
  try
    http := TidHttp.Create(nil);
    http.ProxyParams.Assign(ProxyParams);
    try
      http.Request.UserAgent:='Delphi OSM Browser';
      xml := http.Get('http://nominatim.openstreetmap.org/search?format=xml&q='+ReplaceStr(text,' ','+'));
      doc := TXMLDocument.Create(nil);
      doc.LoadFromXML(xml);
      place:=doc.DocumentElement.ChildNodes[0];
      lat:=StrToFloat(ReplaceStr(place.Attributes['lat'],'.',','));
      lon:=StrToFloat(ReplaceStr(place.Attributes['lon'],'.',','));
      result:=True;
    finally
      FreeAndNil(http);
    end;
  except
    result:=false;
  end;
end;

procedure TOsm.TileLoaded(aTile: TTile);
begin
  if assigned(FOnTileLoaded) then
    FOnTileLoaded(aTile);
end;

end.
