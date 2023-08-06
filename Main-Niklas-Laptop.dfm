object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Openweather'
  ClientHeight = 205
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.SheetOfGlass = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 337
    Height = 205
    Hint = 'H'#246'gerklicka f'#246'r inst'#228'llningar'
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier'
    Font.Style = []
    Lines.Strings = (
      'Memo1')
    ParentFont = False
    ParentShowHint = False
    PopupMenu = PopupMenu1
    ShowHint = True
    TabOrder = 0
  end
  object Timer1: TTimer
    Interval = 55000
    OnTimer = Timer1Timer
    Left = 24
    Top = 72
  end
  object PopupMenu1: TPopupMenu
    Left = 120
    Top = 72
    object Instllningar1: TMenuItem
      Caption = 'Inst'#228'llningar'
      OnClick = SettingsClick
    end
  end
end
