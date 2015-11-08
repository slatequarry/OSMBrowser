unit uOSM;

interface

uses
  System.Classes, System.SysUtils,
  IdHTTPHeaderInfo, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  StrUtils, Xml.XMLIntf, Xml.XMLDoc, Math,
  Vcl.Graphics, Vcl.Imaging.pngimage;

type
  TOsm = class
  private
    FProxyParams  :TIdProxyConnectionInfo;
  public
    property ProxyParams :TIdProxyConnectionInfo read FProxyParams;
    constructor Create;
    function getTile(zoom, xtile, ytile :integer) :tBitmap;
    procedure CoordsToTile(lat_deg, lon_deg :double; zoom :integer; var xtile, ytile :integer);
    function Search(text :string; var lat,lon :double) :boolean;
  end;

implementation

constructor TOsm.Create;
begin
  FProxyParams:=TIdProxyConnectionInfo.Create;
end;

function TOsm.getTile(zoom, xtile, ytile :integer) :tBitmap;
var http    :TidHttp;
    url     :string;
    stream  :TMemoryStream;
    png     :TPngImage;
    bmp     :TBitmap;
begin
  http := TidHttp.Create(nil);
  http.ProxyParams.Assign(FProxyParams);
  try
    stream:=TMemoryStream.Create;
    try
      url:='http://a.tile.openstreetmap.org/'+IntToStr(zoom)+'/'+IntToStr(xtile)+'/'+IntToStr(ytile)+'.png';
      http.Get(url,stream);
      stream.Position:=0;
      png:=TPngImage.Create;
      try
        png.LoadFromStream(stream);
        bmp:=TBitmap.Create;
        bmp.Assign(png);
        result:=bmp;
      finally
        FreeAndNil(png);
      end;
    finally
      FreeAndNil(stream);
    end;
  finally
    FreeAndNil(http);
  end;
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
    xcount,ycount :integer;
    x,y     :integer;
    zoom    :integer;
begin
  result:=False;
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
end;

end.
