object FAPrincipal: TFAPrincipal
  Left = 294
  Top = 143
  ActiveControl = eCentro
  Caption = 'ASIGNACION FRUTA TERCEROS'
  ClientHeight = 457
  ClientWidth = 722
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pEmpresa: TPanel
    Left = 0
    Top = 0
    Width = 722
    Height = 113
    Align = alTop
    TabOrder = 0
    object nbLabel1: TnbLabel
      Left = 22
      Top = 24
      Width = 68
      Height = 21
      Caption = 'Empresa'
      About = 'NB 0.1/20020725'
    end
    object nbLabel2: TnbLabel
      Left = 22
      Top = 48
      Width = 110
      Height = 21
      Caption = 'Comienzo Ejercicio'
      About = 'NB 0.1/20020725'
    end
    object txtFechaIni: TnbStaticText
      Left = 252
      Top = 72
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object txtFechaFin: TnbStaticText
      Left = 353
      Top = 72
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object nbLabel4: TnbLabel
      Left = 249
      Top = 24
      Width = 59
      Height = 21
      Caption = 'Centro'
      About = 'NB 0.1/20020725'
    end
    object eEmpresa: TnbDBSQLCombo
      Left = 140
      Top = 24
      Width = 52
      Height = 21
      About = 'NB 0.1/20020725'
      CharCase = ecUpperCase
      OnChange = eEmpresaChange
      TabOrder = 0
      DatabaseName = 'DBPrincipal'
      OnGetSQL = eEmpresaGetSQL
      FillAuto = True
      NumChars = 3
    end
    object btnSalir: TBitBtn
      Left = 565
      Top = 22
      Width = 142
      Height = 25
      Caption = 'Cerrar Aplicaci'#243'n [Esc]'
      TabOrder = 5
      TabStop = False
      OnClick = btnSalirClick
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00388888888877
        F7F787F8888888888333333F00004444400888FFF444448888888888F333FF8F
        000033334D5007FFF4333388888888883338888F0000333345D50FFFF4333333
        338F888F3338F33F000033334D5D0FFFF43333333388788F3338F33F00003333
        45D50FEFE4333333338F878F3338F33F000033334D5D0FFFF43333333388788F
        3338F33F0000333345D50FEFE4333333338F878F3338F33F000033334D5D0FFF
        F43333333388788F3338F33F0000333345D50FEFE4333333338F878F3338F33F
        000033334D5D0EFEF43333333388788F3338F33F0000333345D50FEFE4333333
        338F878F3338F33F000033334D5D0EFEF43333333388788F3338F33F00003333
        4444444444333333338F8F8FFFF8F33F00003333333333333333333333888888
        8888333F00003333330000003333333333333FFFFFF3333F00003333330AAAA0
        333333333333888888F3333F00003333330000003333333333338FFFF8F3333F
        0000}
      NumGlyphs = 2
    end
    object eFecha: TnbDBCalendarCombo
      Left = 140
      Top = 48
      Width = 90
      Height = 21
      About = 'NB 0.1/20020725'
      CharCase = ecUpperCase
      Text = '30/07/2008'
      OnChange = eFechaChange
      TabOrder = 2
    end
    object btnIrAProducto: TButton
      Left = 488
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Continuar [F5]'
      TabOrder = 4
      OnClick = btnIrAProductoClick
    end
    object eCentro: TnbDBSQLCombo
      Left = 310
      Top = 24
      Width = 39
      Height = 21
      About = 'NB 0.1/20020725'
      CharCase = ecUpperCase
      OnChange = eCentroChange
      TabOrder = 1
      DatabaseName = 'DBPrincipal'
      ColumnResult = 1
      OnGetSQL = eCentroGetSQL
      OnlyNumbers = False
      NumChars = 1
    end
    object cbSemestres: TComboBox
      Left = 252
      Top = 48
      Width = 181
      Height = 21
      ItemHeight = 13
      ItemIndex = 2
      TabOrder = 3
      Text = 'Seleccion Semestre'
      OnClick = cbSemestresClick
      Items.Strings = (
        '1'#186' Semestre'
        '2'#186' Semestre'
        'Seleccion Semestre')
    end
  end
  object pProducto: TPanel
    Left = 0
    Top = 113
    Width = 722
    Height = 65
    Align = alTop
    Enabled = False
    TabOrder = 1
    object nbLabel3: TnbLabel
      Left = 22
      Top = 24
      Width = 68
      Height = 21
      Caption = 'Producto'
      About = 'NB 0.1/20020725'
    end
    object eProducto: TnbDBSQLCombo
      Left = 93
      Top = 24
      Width = 76
      Height = 21
      About = 'NB 0.1/20020725'
      CharCase = ecUpperCase
      OnChange = eProductoChange
      TabOrder = 0
      DatabaseName = 'DBPrincipal'
      OnGetSQL = eProductoGetSQL
      OnlyNumbers = False
    end
    object btnIrACosecheros: TButton
      Left = 488
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Continuar [F5]'
      Enabled = False
      TabOrder = 1
      OnClick = btnIrACosecherosClick
    end
    object btnVolverAEmpresa: TButton
      Left = 565
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Volver [Esc]'
      Enabled = False
      TabOrder = 2
      OnClick = btnVolverAEmpresaClick
    end
  end
  object pCosechero: TPanel
    Left = 0
    Top = 178
    Width = 722
    Height = 65
    Align = alTop
    Enabled = False
    TabOrder = 2
    object nbLabel5: TnbLabel
      Left = 22
      Top = 24
      Width = 68
      Height = 21
      Caption = 'Cosecheros'
      About = 'NB 0.1/20020725'
    end
    object btnAddCosechero: TSpeedButton
      Left = 146
      Top = 23
      Width = 23
      Height = 22
      Caption = '+'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnAddCosecheroClick
    end
    object txtCosecheros: TnbStaticText
      Left = 173
      Top = 24
      Width = 190
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eCosecheros: TnbDBSQLCombo
      Left = 93
      Top = 24
      Width = 52
      Height = 21
      About = 'NB 0.1/20020725'
      CharCase = ecUpperCase
      TabOrder = 0
      DatabaseName = 'DBPrincipal'
      OnGetSQL = eCosecherosGetSQL
    end
    object btnIrAKilos: TButton
      Left = 488
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Continuar [F5]'
      Enabled = False
      TabOrder = 1
      OnClick = btnIrAKilosClick
    end
    object btnVolverAProducto: TButton
      Left = 565
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Volver [Esc]'
      Enabled = False
      TabOrder = 2
      OnClick = btnVolverAProductoClick
    end
    object btnLimpiarLista: TButton
      Left = 367
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Limpiar Lista'
      Enabled = False
      TabOrder = 3
      OnClick = btnLimpiarListaClick
    end
  end
  object PKilos: TPanel
    Left = 0
    Top = 243
    Width = 722
    Height = 214
    Align = alTop
    Enabled = False
    TabOrder = 3
    object eTercerTotal: TnbStaticText
      Left = 310
      Top = 172
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eTercerBotado: TnbStaticText
      Left = 310
      Top = 142
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eTercerDestrio: TnbStaticText
      Left = 310
      Top = 118
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eTercerTercera: TnbStaticText
      Left = 310
      Top = 94
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eTercerSegunda: TnbStaticText
      Left = 310
      Top = 70
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eTercerPrimera: TnbStaticText
      Left = 310
      Top = 46
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object nbLabel14: TnbLabel
      Left = 310
      Top = 22
      Width = 86
      Height = 21
      Caption = '  YA Asignado'
      About = 'NB 0.1/20020725'
    end
    object nbLabel6: TnbLabel
      Left = 22
      Top = 46
      Width = 107
      Height = 21
      Caption = 'Primera (1)'
      About = 'NB 0.1/20020725'
    end
    object nbLabel7: TnbLabel
      Left = 22
      Top = 70
      Width = 107
      Height = 21
      Caption = 'Segunda (2)'
      About = 'NB 0.1/20020725'
    end
    object nbLabel8: TnbLabel
      Left = 22
      Top = 94
      Width = 107
      Height = 21
      Caption = 'Tercera (3)'
      About = 'NB 0.1/20020725'
    end
    object nbLabel9: TnbLabel
      Left = 22
      Top = 118
      Width = 107
      Height = 21
      Caption = 'Destrio (2B/3B)'
      About = 'NB 0.1/20020725'
    end
    object nbLabel10: TnbLabel
      Left = 22
      Top = 142
      Width = 107
      Height = 21
      Caption = 'Merma / Botado (B)'
      About = 'NB 0.1/20020725'
    end
    object eInPrimera: TnbStaticText
      Left = 135
      Top = 46
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eInSegunda: TnbStaticText
      Left = 135
      Top = 70
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eInTercera: TnbStaticText
      Left = 135
      Top = 94
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eInDestrio: TnbStaticText
      Left = 135
      Top = 118
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eOutPrimera: TnbStaticText
      Left = 223
      Top = 46
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eOutSegunda: TnbStaticText
      Left = 223
      Top = 70
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eOutTercera: TnbStaticText
      Left = 223
      Top = 94
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eOutDestrio: TnbStaticText
      Left = 223
      Top = 118
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eOutBotado: TnbStaticText
      Left = 223
      Top = 142
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object nbLabel11: TnbLabel
      Left = 135
      Top = 22
      Width = 80
      Height = 21
      Caption = 'Entrada Cosec.'
      About = 'NB 0.1/20020725'
    end
    object nbLabel12: TnbLabel
      Left = 223
      Top = 22
      Width = 80
      Height = 21
      Caption = 'Total Salida'
      About = 'NB 0.1/20020725'
    end
    object nbLabel13: TnbLabel
      Left = 398
      Top = 22
      Width = 80
      Height = 21
      Caption = 'Asignar'
      About = 'NB 0.1/20020725'
    end
    object eInBotado: TnbStaticText
      Left = 135
      Top = 142
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object nbLabel15: TnbLabel
      Left = 22
      Top = 172
      Width = 107
      Height = 21
      Caption = 'TOTAL'
      About = 'NB 0.1/20020725'
    end
    object eInTotal: TnbStaticText
      Left = 135
      Top = 172
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eOutTotal: TnbStaticText
      Left = 223
      Top = 172
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object eTotal: TnbStaticText
      Left = 398
      Top = 172
      Width = 80
      Height = 21
      About = 'NB 0.1/20020725'
    end
    object nbLabel16: TnbLabel
      Left = 398
      Top = 6
      Width = 80
      Height = 21
      Caption = ' Kilos PDTE'
      About = 'NB 0.1/20020725'
    end
    object nbLabel17: TnbLabel
      Left = 310
      Top = 6
      Width = 80
      Height = 21
      Caption = '    Tercero'
      About = 'NB 0.1/20020725'
    end
    object nbLabel18: TnbLabel
      Left = 482
      Top = 94
      Width = 111
      Height = 21
      Caption = '(NO se asignan kilos)'
      About = 'NB 0.1/20020725'
    end
    object nbLabel19: TnbLabel
      Left = 482
      Top = 118
      Width = 111
      Height = 21
      Caption = '(NO se asignan kilos)'
      About = 'NB 0.1/20020725'
    end
    object nbLabel20: TnbLabel
      Left = 482
      Top = 142
      Width = 111
      Height = 21
      Caption = '(NO se asignan kilos)'
      About = 'NB 0.1/20020725'
    end
    object btnAplicar: TButton
      Left = 488
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Aplicar [F5]'
      Enabled = False
      TabOrder = 0
      OnClick = btnAplicarClick
    end
    object btnCancelar: TButton
      Left = 565
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Cancelar [Esc]'
      Enabled = False
      TabOrder = 1
      OnClick = btnCancelarClick
    end
    object ePrimera: TBEdit
      Left = 398
      Top = 46
      Width = 80
      Height = 21
      InputType = itReal
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -5
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      TabOrder = 2
      OnChange = eKilosChange
    end
    object eSegunda: TBEdit
      Left = 398
      Top = 70
      Width = 80
      Height = 21
      InputType = itReal
      TabOrder = 3
      OnChange = eKilosChange
    end
    object eTercera: TBEdit
      Left = 398
      Top = 94
      Width = 80
      Height = 21
      InputType = itReal
      TabOrder = 4
      OnChange = eKilosChange
    end
    object eDestrio: TBEdit
      Left = 398
      Top = 118
      Width = 80
      Height = 21
      InputType = itReal
      TabOrder = 5
      OnChange = eKilosChange
    end
    object eBotado: TBEdit
      Left = 398
      Top = 142
      Width = 80
      Height = 21
      InputType = itReal
      TabOrder = 6
      OnChange = eKilosChange
    end
    object btnBorrar: TButton
      Left = 488
      Top = 53
      Width = 152
      Height = 25
      Caption = 'Borrar Asignacion'
      TabOrder = 7
      OnClick = btnBorrarClick
    end
  end
end
