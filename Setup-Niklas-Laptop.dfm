object SetupForm: TSetupForm
  Left = 0
  Top = 0
  Hint = 'H'#246'gerklicka f'#246'r inst'#228'llningar'
  Caption = 'Inst'#228'llningar'
  ClientHeight = 221
  ClientWidth = 380
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 74
    Height = 13
    Hint = 'P'
    Caption = 'Plats f'#246'r "takfil"'
  end
  object Edit1: TEdit
    Left = 24
    Top = 24
    Width = 337
    Height = 21
    TabOrder = 0
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 286
    Top = 51
    Width = 75
    Height = 25
    Caption = '&V'#228'lj fil'
    TabOrder = 1
    OnClick = Button1Click
  end
  object OpenTextFileDialog1: TOpenTextFileDialog
    Left = 304
    Top = 160
  end
end
