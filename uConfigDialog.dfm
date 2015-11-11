object frmConfig: TfrmConfig
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Einstellungen'
  ClientHeight = 342
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 301
    Width = 564
    Height = 41
    Align = alBottom
    TabOrder = 3
    object btnOk: TBitBtn
      Left = 337
      Top = 8
      Width = 89
      Height = 25
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
    end
    object btnCancel: TBitBtn
      Left = 448
      Top = 8
      Width = 89
      Height = 25
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 1
    end
  end
  object boxProxy: TGroupBox
    Left = 0
    Top = 141
    Width = 564
    Height = 160
    Align = alClient
    Caption = 'Proxy'
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 25
      Width = 97
      Height = 13
      Caption = 'Basic Authentication'
      FocusControl = chkBasicAuth
    end
    object Label2: TLabel
      Left = 16
      Top = 50
      Width = 32
      Height = 13
      Caption = 'Server'
      FocusControl = edtServer
    end
    object Label3: TLabel
      Left = 16
      Top = 77
      Width = 20
      Height = 13
      Caption = 'Port'
    end
    object Label4: TLabel
      Left = 16
      Top = 104
      Width = 43
      Height = 13
      Caption = 'Benutzer'
      FocusControl = edtUser
    end
    object Label5: TLabel
      Left = 16
      Top = 132
      Width = 44
      Height = 13
      Caption = 'Passwort'
      FocusControl = edtPassword
    end
    object chkBasicAuth: TCheckBox
      Left = 120
      Top = 24
      Width = 17
      Height = 17
      TabOrder = 0
    end
    object edtServer: TEdit
      Left = 72
      Top = 47
      Width = 473
      Height = 21
      TabOrder = 1
    end
    object edtUser: TEdit
      Left = 72
      Top = 101
      Width = 201
      Height = 21
      TabOrder = 3
    end
    object edtPassword: TEdit
      Left = 72
      Top = 129
      Width = 201
      Height = 21
      TabOrder = 4
    end
    object edtPort: TJvSpinEdit
      Left = 72
      Top = 74
      Width = 73
      Height = 21
      MaxValue = 9999.000000000000000000
      TabOrder = 2
    end
  end
  object boxStart: TGroupBox
    Left = 0
    Top = 57
    Width = 564
    Height = 84
    Align = alTop
    Caption = 'Start'
    TabOrder = 2
    object lblStartsearch: TLabel
      Left = 16
      Top = 26
      Width = 29
      Height = 13
      Caption = 'Suche'
      FocusControl = edtServer
    end
    object lblZoom: TLabel
      Left = 16
      Top = 54
      Width = 26
      Height = 13
      Caption = 'Zoom'
      FocusControl = edtServer
    end
    object edtStartsearch: TEdit
      Left = 72
      Top = 23
      Width = 473
      Height = 21
      TabOrder = 0
    end
    object edtZoom: TJvSpinEdit
      Left = 72
      Top = 50
      Width = 57
      Height = 21
      MaxValue = 19.000000000000000000
      MinValue = 1.000000000000000000
      Value = 1.000000000000000000
      TabOrder = 1
    end
  end
  object boxTileUrl: TGroupBox
    Left = 0
    Top = 0
    Width = 564
    Height = 57
    Align = alTop
    Caption = 'Karten-Dienst'
    TabOrder = 0
    object Label6: TLabel
      Left = 16
      Top = 25
      Width = 33
      Height = 13
      Caption = 'Tile-Url'
      FocusControl = cbbTileUrl
    end
    object cbbTileUrl: TComboBox
      Left = 72
      Top = 22
      Width = 473
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      Items.Strings = (
        'http://a.tile.openstreetmap.org/${z}/${x}/${y}.png'
        'http://otile1.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.jpg'
        'http://a.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png'
        'http://a.tile.thunderforest.com/landscape/${z}/${x}/${y}.png'
        'http://a.tile.thunderforest.com/outdoors/${z}/${x}/${y}.png')
    end
  end
end
