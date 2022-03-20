object frmHelp: TfrmHelp
  Left = 640
  Top = 312
  Align = alCustom
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Help'
  ClientHeight = 423
  ClientWidth = 623
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Help: TMemo
    Left = -4
    Top = 0
    Width = 621
    Height = 321
    Align = alCustom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'Help')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 248
    Top = 348
    Width = 129
    Height = 45
    Caption = 'OK'
    TabOrder = 1
    OnClick = btnOKClick
  end
end
