object SetupForm: TSetupForm
  Left = 0
  Top = 0
  Hint = 'H'#246'gerklicka f'#246'r inst'#228'llningar'
  Caption = 'Inst'#228'llningar'
  ClientHeight = 366
  ClientWidth = 467
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnActivate = FormActivate
  TextHeight = 13
  object Bevel1: TBevel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 461
    Height = 360
    Align = alClient
    ExplicitLeft = 8
    ExplicitTop = -2
    ExplicitWidth = 465
    ExplicitHeight = 361
  end
  object Label4: TLabel
    Left = 24
    Top = 157
    Width = 73
    Height = 13
    Hint = 'P'
    Caption = 'Max vindstyrka'
  end
  object Label5: TLabel
    Left = 24
    Top = 218
    Width = 111
    Height = 13
    Hint = 'P'
    Caption = 'Open Weather API key'
  end
  object Label3: TLabel
    Left = 120
    Top = 101
    Width = 43
    Height = 13
    Hint = 'P'
    Caption = 'Latitude:'
  end
  object Label2: TLabel
    Left = 24
    Top = 101
    Width = 51
    Height = 13
    Hint = 'P'
    Caption = 'Longitude:'
  end
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 74
    Height = 13
    Hint = 'P'
    Caption = 'Plats f'#246'r "takfil"'
  end
  object Label6: TLabel
    Left = 120
    Top = 157
    Width = 196
    Height = 13
    Hint = 'P'
    Caption = 'Sekunder mellan uppdatering av  v'#228'derfil'
  end
  object EditFile: TEdit
    Left = 24
    Top = 24
    Width = 337
    Height = 21
    TabOrder = 0
    Text = 'EditFile'
  end
  object ButtonChooseFile: TButton
    Left = 367
    Top = 22
    Width = 75
    Height = 25
    Caption = '&V'#228'lj fil'
    TabOrder = 1
    OnClick = ButtonChooseFileClick
  end
  object EditLong: TEdit
    Left = 24
    Top = 120
    Width = 65
    Height = 21
    TabOrder = 2
    Text = 'Long'
  end
  object EditLat: TEdit
    Left = 120
    Top = 120
    Width = 65
    Height = 21
    TabOrder = 3
    Text = 'Lat'
  end
  object ButtonOK: TButton
    Left = 361
    Top = 334
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 4
    OnClick = ButtonOKClick
  end
  object EditWind: TEdit
    Left = 24
    Top = 176
    Width = 65
    Height = 21
    Hint = 'Max s'#228'ker vindstyrka'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    Text = 'vindstyrka'
  end
  object EditAPI: TEdit
    Left = 24
    Top = 237
    Width = 412
    Height = 21
    Hint = 'API key fr'#229'n Openweather.com'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    Text = 'API-Key'
  end
  object EditWeatherFilename: TEdit
    Left = 24
    Top = 305
    Width = 281
    Height = 21
    TabOrder = 7
    Text = 'Filnamn...'
  end
  object BitBtn1: TBitBtn
    Left = 311
    Top = 303
    Width = 75
    Height = 25
    Caption = 'V'#228'lj ...'
    Default = True
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    ModalResult = 6
    NumGlyphs = 2
    TabOrder = 8
    OnClick = BitBtn1Click
  end
  object CheckBoxWD: TCheckBox
    Left = 24
    Top = 282
    Width = 97
    Height = 17
    Hint = 'Sparar historiska v'#228'derdata alteftersom'
    Caption = 'Spara v'#228'derdata continuerligt till:'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
  end
  object EditSecondsUpdate: TEdit
    Left = 120
    Top = 176
    Width = 65
    Height = 21
    Hint = 'Tid i sekunder mellan uppdatering av weather.txt'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 10
    Text = '15'
  end
  object OpenTextFileDialog1: TOpenTextFileDialog
    Left = 216
    Top = 56
  end
  object OpenTextFileDialog2: TOpenTextFileDialog
    Left = 376
    Top = 192
  end
end
