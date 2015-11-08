object frmOSMbrowser: TfrmOSMbrowser
  Left = 0
  Top = 0
  Caption = 'OSM Browser'
  ClientHeight = 742
  ClientWidth = 984
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlSearch: TPanel
    Left = 0
    Top = 0
    Width = 984
    Height = 33
    Align = alTop
    AutoSize = True
    BorderWidth = 5
    TabOrder = 0
    object btnSearch: TButton
      Left = 921
      Top = 6
      Width = 57
      Height = 21
      Align = alRight
      Caption = 'Suche'
      TabOrder = 0
      OnClick = btnSearchClick
    end
    object edtSearch: TEdit
      Left = 6
      Top = 6
      Width = 915
      Height = 21
      Align = alClient
      TabOrder = 1
    end
  end
  object PageControl: TPageControl
    Left = 0
    Top = 33
    Width = 984
    Height = 709
    ActivePage = tabKarte
    Align = alClient
    TabOrder = 1
    TabPosition = tpBottom
    object tabKarte: TTabSheet
      Caption = 'Karte'
      DesignSize = (
        976
        683)
      object PaintBox: TPaintBox
        Left = 0
        Top = 0
        Width = 976
        Height = 683
        Align = alClient
        OnPaint = PaintBoxPaint
        ExplicitLeft = 416
        ExplicitTop = 136
        ExplicitWidth = 105
        ExplicitHeight = 105
      end
      object slZoom: TJvxSlider
        Left = 3
        Top = 643
        Width = 150
        Height = 40
        Increment = 1
        MinValue = 1
        MaxValue = 19
        Options = [soShowPoints, soSmooth]
        TabOrder = 0
        Value = 1
        Anchors = [akLeft, akBottom]
        OnChange = slZoomChange
      end
    end
    object tabMemo: TTabSheet
      Caption = 'Debug'
      ImageIndex = 1
      object Memo: TMemo
        Left = 0
        Top = 0
        Width = 976
        Height = 683
        Align = alClient
        TabOrder = 0
      end
    end
  end
  object IdHTTP: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = True
    ProxyParams.ProxyPassword = 'vogtvogt'
    ProxyParams.ProxyPort = 8080
    ProxyParams.ProxyServer = 'proxy.leh.vogt-electronic.com'
    ProxyParams.ProxyUsername = 'automatic'
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Delphi OSM Browser'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 24
    Top = 40
  end
  object MainMenu: TMainMenu
    Left = 24
    Top = 88
    object mnuConfig: TMenuItem
      Caption = '&Einstellungen'
      OnClick = mnuConfigClick
    end
    object mnuQuit: TMenuItem
      Caption = 'Be&enden'
      OnClick = mnuQuitClick
    end
  end
  object JvAppIni: TJvAppIniFileStorage
    StorageOptions.BooleanStringTrueValues = 'TRUE, YES, Y'
    StorageOptions.BooleanStringFalseValues = 'FALSE, NO, N'
    AutoFlush = True
    FileName = 'OSMBrowser.ini'
    Location = flUserFolder
    SubStorages = <>
    Left = 24
    Top = 136
  end
end
