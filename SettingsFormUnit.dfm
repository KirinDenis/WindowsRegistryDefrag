object SettingsForm: TSettingsForm
  Left = 360
  Top = 303
  BorderStyle = bsDialog
  Caption = 'Settings...'
  ClientHeight = 373
  ClientWidth = 437
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 345
    Top = 343
    Width = 75
    Height = 22
    Cursor = crHandPoint
    Caption = 'Close'
    Flat = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3223857
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = SpeedButton1Click
  end
  object Image2: TImage
    Left = 12
    Top = 346
    Width = 16
    Height = 16
    Picture.Data = {
      07544269746D617036040000424D360400000000000036000000280000001000
      0000100000000100200000000000000400000000000000000000000000000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00F7F7F700BDB5B5009C948C009484
      8400948484009C948C00BDB5B500EFEFEF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00BDB5B50094736300B57B6B00C6948400CE94
      8C00CE948C00BD8C7B00A56B5A0084635200BDB5B500FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00A59C9C008C4A3100A56B5200AD735A00AD736300AD73
      6300AD736300AD736300A56B5A00A5634A0084422900A59C9C00FF00FF00FF00
      FF00FF00FF00BDB5B500944A31008C4A2900944A3100944A31009C5239009C5A
      42009C524200944A31008C4A31008C4A29008C42210073311000BDB5B500FF00
      FF00EFEFEF009C6B63009C5A42006B21080084311000843918008C4221008C42
      21008C4221008C4A3100843918007B3110008C4A2900944A31007B5A4A00F7F7
      F700B5ADAD00CE8C8400AD7B6B00733118007B2908007B3110007B3110007B29
      08008C392100D6B5B500BD8C7B007B3110006B311800BD8C8400AD736300BDB5
      B500A5847300CE948C00D6ADA500BD948C00733118007B2908007B3110007321
      0000A56B5A00EFE7E700E7CECE00A56B5A0063210800A56B5A009C5A42009484
      7B009C736300CE9C8C00D6A59C00DEBDB5008C5A4A0073290800843110007321
      0000B58C7B00FF00FF00EFD6D600D6B5B5007B3921008C4A31009C4A31008C6B
      63009C6B6300D69C9400D6A59C00AD847300844A31008C4A2900A5635200AD7B
      6B00DECEC600FF00FF00EFD6D600E7CECE00BD948C00945A4A00A5634A009473
      6B009C736300A56B52008C523900A5635200A5634A00AD7B6B00EFDED600F7F7
      F700FF00FF00EFE7E700EFDED600DECEC600D6B5B500BD948C00C6847B009C84
      8400AD9C94009C52390094634A00AD847300B5846B00C69C8C00EFDEDE00F7E7
      E700F7E7E700EFDEDE00EFDED600E7CECE00E7CEC600DEBDB500B57B6B00BDB5
      B500E7E7E700A5635200CEAD9C00B59C9400BD9C8C00BD9C8C00CEAD9C00EFD6
      D600DECECE00DECEC600DECEC600EFD6D600E7D6CE00E7C6BD00946B5A00F7F7
      F700FF00FF00AD9C9400D6ADA500EFDED600CEBDBD00CEB5AD00CEB5AD00DECE
      C600EFE7DE00EFE7DE00EFDED600EFDED600F7E7E700CEA59400BDB5B500FF00
      FF00FF00FF00FFFFFF00A5847B00E7C6C600FFF7F700EFE7E700EFDEDE00EFE7
      DE00FF00FF00FF00FF00FF00FF00FFF7F700E7C6BD00AD9C9400FF00FF00FF00
      FF00FF00FF00FF00FF00FFFFFF00C6A59C00C6A59400EFE7DE00F7F7F700FFF7
      F700FFFFFF00FFF7F700F7E7E700C6A59C00B5ADAD00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00EFDEDE00C6A59400B58C7B00B58C
      7B00B5847300AD847300BDA5A500E7E7E700FF00FF00FF00FF00FF00FF00FF00
      FF00}
    Transparent = True
  end
  object Label1: TLabel
    Left = 39
    Top = 348
    Width = 92
    Height = 13
    Caption = 'product homepage:'
  end
  object Label2: TLabel
    Left = 140
    Top = 348
    Width = 144
    Height = 13
    Cursor = crHandPoint
    Caption = 'http://product.homepage'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3223857
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = Label2Click
    OnMouseMove = Label2MouseMove
  end
  object Label3: TLabel
    Left = 49
    Top = 14
    Width = 57
    Height = 16
    Caption = 'Settings'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3223857
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label4: TLabel
    Left = 50
    Top = 50
    Width = 268
    Height = 13
    Caption = 'setup Registry Defrag 2010 settings before use'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3223857
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 35
    Top = 86
    Width = 196
    Height = 13
    Caption = 'backup system files before defrag:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3223857
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 35
    Top = 163
    Width = 194
    Height = 13
    Caption = 'automatickly checking for update:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3223857
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 35
    Top = 111
    Width = 363
    Height = 38
    AutoSize = False
    Caption = 
      'make backup copy of all your system files befor defrag your regi' +
      'stry. It take more time for defrag processing, but we recomend t' +
      'o do so.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3223857
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
    WordWrap = True
  end
  object Label8: TLabel
    Left = 35
    Top = 190
    Width = 353
    Height = 32
    AutoSize = False
    Caption = 
      'checking for a new version everi time when registry defrag start' +
      'up.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3223857
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    Transparent = True
    WordWrap = True
  end
  object Label9: TLabel
    Left = 340
    Top = 296
    Width = 70
    Height = 13
    Cursor = crHandPoint
    Alignment = taRightJustify
    Caption = 'Apply changes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3223857
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    Transparent = True
    OnClick = Label9Click
    OnMouseMove = Label2MouseMove
  end
  object ComboBox1: TComboBox
    Left = 360
    Top = 84
    Width = 50
    Height = 21
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3223857
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 13
    ItemIndex = 0
    ParentFont = False
    TabOrder = 0
    Text = 'Yes'
    Items.Strings = (
      'Yes'
      'No')
  end
  object ComboBox2: TComboBox
    Left = 360
    Top = 161
    Width = 50
    Height = 21
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3223857
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 13
    ItemIndex = 0
    ParentFont = False
    TabOrder = 1
    Text = 'Yes'
    Items.Strings = (
      'Yes'
      'No')
  end
end
