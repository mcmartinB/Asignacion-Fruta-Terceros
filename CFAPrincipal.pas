unit CFAPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, nbEdits, nbCombos, nbLabels, ExtCtrls, Buttons, BEdit;

type
  TFAPrincipal = class(TForm)
    pEmpresa: TPanel;
    nbLabel1: TnbLabel;
    eEmpresa: TnbDBSQLCombo;
    btnSalir: TBitBtn;
    nbLabel2: TnbLabel;
    eFecha: TnbDBCalendarCombo;
    txtFechaIni: TnbStaticText;
    txtFechaFin: TnbStaticText;
    pProducto: TPanel;
    pCosechero: TPanel;
    PKilos: TPanel;
    btnIrAProducto: TButton;
    nbLabel3: TnbLabel;
    eProducto: TnbDBSQLCombo;
    btnIrACosecheros: TButton;
    btnVolverAEmpresa: TButton;
    nbLabel4: TnbLabel;
    eCentro: TnbDBSQLCombo;
    nbLabel5: TnbLabel;
    eCosecheros: TnbDBSQLCombo;
    btnAddCosechero: TSpeedButton;
    txtCosecheros: TnbStaticText;
    btnIrAKilos: TButton;
    btnVolverAProducto: TButton;
    btnAplicar: TButton;
    btnCancelar: TButton;
    nbLabel6: TnbLabel;
    nbLabel7: TnbLabel;
    nbLabel8: TnbLabel;
    nbLabel9: TnbLabel;
    nbLabel10: TnbLabel;
    eInPrimera: TnbStaticText;
    eInSegunda: TnbStaticText;
    eInTercera: TnbStaticText;
    eInDestrio: TnbStaticText;
    eOutPrimera: TnbStaticText;
    eOutSegunda: TnbStaticText;
    eOutTercera: TnbStaticText;
    eOutDestrio: TnbStaticText;
    eOutBotado: TnbStaticText;
    ePrimera: TBEdit;
    eSegunda: TBEdit;
    eTercera: TBEdit;
    eDestrio: TBEdit;
    eBotado: TBEdit;
    nbLabel11: TnbLabel;
    nbLabel12: TnbLabel;
    nbLabel13: TnbLabel;
    nbLabel14: TnbLabel;
    eTercerPrimera: TnbStaticText;
    eTercerSegunda: TnbStaticText;
    eTercerTercera: TnbStaticText;
    eTercerDestrio: TnbStaticText;
    eTercerBotado: TnbStaticText;
    eInBotado: TnbStaticText;
    nbLabel15: TnbLabel;
    eInTotal: TnbStaticText;
    eOutTotal: TnbStaticText;
    eTercerTotal: TnbStaticText;
    eTotal: TnbStaticText;
    btnLimpiarLista: TButton;
    cbSemestres: TComboBox;
    nbLabel16: TnbLabel;
    nbLabel17: TnbLabel;
    btnBorrar: TButton;
    nbLabel18: TnbLabel;
    nbLabel19: TnbLabel;
    nbLabel20: TnbLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSalirClick(Sender: TObject);
    procedure eEmpresaChange(Sender: TObject);
    function eEmpresaGetSQL: String;
    procedure btnIrAProductoClick(Sender: TObject);
    function eProductoGetSQL: String;
    function eCentroGetSQL: String;
    procedure eCentroChange(Sender: TObject);
    procedure eProductoChange(Sender: TObject);
    procedure btnIrACosecherosClick(Sender: TObject);
    procedure btnVolverAEmpresaClick(Sender: TObject);
    function eCosecherosGetSQL: String;
    procedure btnAddCosecheroClick(Sender: TObject);
    procedure btnIrAKilosClick(Sender: TObject);
    procedure btnVolverAProductoClick(Sender: TObject);
    procedure btnAplicarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure eKilosChange(Sender: TObject);
    procedure btnLimpiarListaClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbPrimeroClick(Sender: TObject);
    procedure cbSegundoClick(Sender: TObject);
    procedure cbSemestresClick(Sender: TObject);
    procedure eFechaChange(Sender: TObject);
    procedure btnBorrarClick(Sender: TObject);
  private
    { Private declarations }
    bCanClose: Boolean;
    sEmpresa, sCentro, sProducto, sFechaIni, sFechaFin, sCosecheros: string;
    dFechaIni, dFechaFin: TDateTime;
    iAnyo, iMes: word;
    slCategorias: TStringList;

    procedure LimpiarCamposKilos;
    procedure CalcularKilos;
    procedure AnyadirCosechero( const ACosechero: string );
  public
    { Public declarations }
  end;

var
  FAPrincipal: TFAPrincipal;

implementation

{$R *.dfm}

uses CDAPrincipal, CDPAsignacionTerceros;

procedure TFAPrincipal.FormCreate(Sender: TObject);
begin
  bCanClose:= False;
  DAPrincipal:= TDAPrincipal.Create( self );
  DAPrincipal.DBPrincipal.Open;
  DPAsignacionTerceros:= TDPAsignacionTerceros.Create( self );

  eEmpresa.Text:= '050';
  eEmpresa.Change;
  eCentro.Text:= '1';
  eCentro.Change;
  eFecha.Text:= DateToStr( Date );
  eFecha.Change;

  slCategorias:= TStringList.Create;
end;

procedure TFAPrincipal.FormShow(Sender: TObject);
begin
  if not DAPrincipal.DBPrincipal.Connected then
  begin
    bCanClose:= True;
    Close;
  end;
end;

procedure TFAPrincipal.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeAndNil( DPAsignacionTerceros );
  FreeAndNil( DAPrincipal );
  FreeAndNil( slCategorias );
end;

procedure TFAPrincipal.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:= bCanClose;
end;

procedure TFAPrincipal.btnSalirClick(Sender: TObject);
begin
  bCanClose:= True;
  Close;
end;

procedure TFAPrincipal.eEmpresaChange(Sender: TObject);
begin
  if Length( eEmpresa.Text ) = 3 then
  begin
    sEmpresa:= eEmpresa.Text;
  end
  else
  begin
    sEmpresa:= '';
  end;
end;

procedure TFAPrincipal.eCentroChange(Sender: TObject);
begin
  if Length( eCentro.Text ) = 1 then
  begin
    sCentro:= eCentro.Text;
  end
  else
  begin
    sCentro:= '';
  end;
end;

function TFAPrincipal.eEmpresaGetSQL: String;
begin
  result:= 'select empresa_e, nombre_e from frf_empresas order by empresa_e';
end;

procedure TFAPrincipal.eFechaChange(Sender: TObject);
begin
  cbSemestres.OnClick(Self);
end;

function TFAPrincipal.eCentroGetSQL: String;
begin
  if sEmpresa <> '' then
  begin
    result:= 'select empresa_c, centro_c, descripcion_c '+
             'from frf_centros ' +
             'where empresa_c = ' + QuotedStr( sEmpresa ) + ' ' +
             'order by 1,2 ';
  end
  else
  begin
    result:= 'select empresa_c, centro_c, descripcion_c ' +
             'from frf_centros ' +
             'order by 1,2 ';
  end;

end;

procedure TFAPrincipal.btnIrAProductoClick(Sender: TObject);
begin
  if ( sEmpresa = '' ) or ( sCentro = '' ) or ( sFechaIni = '' ) or ( sFechaFin = '' ) then
  begin
    ShowMessage('Faltan datos (Empresa,Centro,Año/Mes)');
    eCentro.SetFocus;
  end
  else
  begin
    //ShowMessage('Seleccione producto ....');

    btnIrAProducto.Enabled:= False;
    btnSalir.Enabled:= False;
    pEmpresa.Enabled:= false;

    pProducto.Enabled:= True;
    btnIrACosecheros.Enabled:= True;
    btnVolverAEmpresa.Enabled:= True;
    eProducto.SetFocus;
  end;
end;

function TFAPrincipal.eProductoGetSQL: String;
begin
  result:= 'select producto_e, descripcion_p ' +
           'from frf_escandallo, frf_productos ' +
           'where empresa_e = ' + QuotedStr( sEmpresa ) + ' ' +
           'and centro_e = ' + QuotedStr( sCentro ) + ' ' +
           'and fecha_e between ' + QuotedStr( sFechaIni ) + ' and ' + QuotedStr( sFechaFin ) + ' ' +
           'and empresa_p = ' + QuotedStr( sEmpresa ) + ' ' +
           'and producto_p = producto_e ' +
           'group by 1,2 ' +
           'order by 1,2 ';
end;

procedure TFAPrincipal.eProductoChange(Sender: TObject);
begin
  if Length( eProducto.Text ) = 3 then
  begin
    sProducto:= eProducto.Text;
  end
  else
  begin
    sProducto:= '';
  end;
end;

procedure TFAPrincipal.btnIrACosecherosClick(Sender: TObject);
begin
  if ( sProducto = '' ) then
  begin
    ShowMessage('Faltan datos (Producto)');
    eProducto.SetFocus;
  end
  else
  begin
    //ShowMessage('Seleccione cosechero ....');
    btnIrACosecheros.Enabled:= False;
    btnVolverAEmpresa.Enabled:= False;
    pProducto.Enabled:= false;

    btnIrAKilos.Enabled:= True;
    btnVolverAProducto.Enabled:= True;
    pCosechero.Enabled:= True;
    eCosecheros.SetFocus;

    slCategorias.Clear;
  end;
end;

procedure TFAPrincipal.btnVolverAEmpresaClick(Sender: TObject);
begin
  eProducto.Text:= '';
  btnIrAProducto.Enabled:= True;
  btnSalir.Enabled:= True;
  pEmpresa.Enabled:= True;
  eCentro.SetFocus;

  pProducto.Enabled:= False;
  btnIrACosecheros.Enabled:= False;
  btnVolverAEmpresa.Enabled:= False;
end;

function TFAPrincipal.eCosecherosGetSQL: String;
begin
  result:= 'select cosechero_e, nombre_c ' +
           'from frf_escandallo, frf_cosecheros ' +
           'where empresa_e = ' + QuotedStr( sEmpresa ) + ' ' +
           'and centro_e = ' + QuotedStr( sCentro ) + ' ' +
           'and fecha_e between ' + QuotedStr( sFechaIni ) + ' and ' + QuotedStr( sFechaFin ) + ' ' +
           'and producto_e = ' + QuotedStr( sProducto ) + ' ' +
           'and empresa_c = ' + QuotedStr( sEmpresa ) + ' ' +
           'and cosechero_c = cosechero_e ' +
           'group by 1,2 ' +
           'order by 1,2 ';
end;

procedure TFAPrincipal.AnyadirCosechero( const ACosechero: string );
var
  i: integer;
  bFlag: boolean;
begin
  i:= 0;
  bFlag:= False;
  while ( i < slCategorias.Count ) and not bFlag do
  begin
    if slCategorias[i] = eCosecheros.Text then
    begin
      bFlag:= True;
    end;
    inc( i );
  end;

  if not bFlag then
  begin
    if txtCosecheros.Caption = '' then
    begin
      txtCosecheros.Caption:= eCosecheros.Text;
    end
    else
    begin
      txtCosecheros.Caption:= txtCosecheros.Caption +', ' + eCosecheros.Text;
    end;
    slCategorias.Add( eCosecheros.Text );
  end;
end;

procedure TFAPrincipal.btnAddCosecheroClick(Sender: TObject);
var
  i: integer;
  bFlag: boolean;
begin
  if Trim( eCosecheros.Text ) <> '' then
  begin
    AnyadirCosechero( Trim( eCosecheros.Text ) );
  end
  else
  begin
    ShowMessage( 'Falta Cosechero.' );
  end;
end;

procedure TFAPrincipal.btnLimpiarListaClick(Sender: TObject);
begin
  txtCosecheros.Caption:= '';
end;

procedure TFAPrincipal.btnIrAKilosClick(Sender: TObject);
begin
  if ( txtCosecheros.Caption = '' ) and ( Trim( eCosecheros.Text ) <> '' ) then
  begin
    ShowMessage('Faltan datos (Cosechero)');
    eCosecheros.SetFocus;
  end
  else
  begin
    if Trim( eCosecheros.Text ) <> '' then
    begin
      AnyadirCosechero( Trim( eCosecheros.Text ) );
    end;
    sCosecheros:= txtCosecheros.Caption;
    //ShowMessage('Inserte la cantidad de kilos de terceros que quiere asignar.');

    btnIrAKilos.Enabled:= False;
    btnVolverAProducto.Enabled:= False;
    pCosechero.Enabled:= false;

    btnAplicar.Enabled:= True;
    btnCancelar.Enabled:= True;
    PKilos.Enabled:= True;

    CalcularKilos;
  end;
end;

procedure TFAPrincipal.CalcularKilos;
var
  rPrimera, rSegunda, rTercera, rDestrio, rBotado,
  rPrimeraIn, rSegundaIn, rTerceraIn, rDestrioIn, rBotadoIn,
  rPrimeraOut, rSegundaOut, rTerceraOut, rDestrioOut, rBotadoOut,
  rPrimeraTer, rSegundaTer, rTerceraTer, rDestrioTer, rBotadoTer: Real;
begin
  DAPrincipal.KilosAprovecha( sEmpresa, sCentro, sProducto, sCosecheros, dFechaini, dFechaFin,
                  rPrimeraIn, rSegundaIn, rTerceraIn, rDestrioIn, rBotadoIn );
  eInPrimera.Caption:= FormatFloat( '0.00',  rPrimeraIn );
  eInSegunda.Caption:= FormatFloat( '0.00', rSegundaIn );
  eInTercera.Caption:= FormatFloat( '0.00', rTerceraIn );
  eInDestrio.Caption:= FormatFloat( '0.00', rDestrioIn );
  eInBotado.Caption:= FormatFloat( '0.00', rBotadoIn );
  eInTotal.Caption:= FormatFloat( '0.00', rPrimeraIn + rSegundaIn + rTerceraIn + rDestrioIn + rBotadoIn );

  DAPrincipal.KilosSalida( sEmpresa, sCentro, sProducto, dFechaini, dFechaFin,
                  rPrimeraOut, rSegundaOut, rTerceraOut, rDestrioOut, rBotadoOut );
  eOutPrimera.Caption:= FormatFloat( '0.00', rPrimeraOut );
  eOutSegunda.Caption:= FormatFloat( '0.00', rSegundaOut );
  eOutTercera.Caption:= FormatFloat( '0.00', rTerceraOut );
  eOutDestrio.Caption:= FormatFloat( '0.00', rDestrioOut );
  eOutBotado.Caption:= FormatFloat( '0.00', rBotadoOut );
  eOutTotal.Caption:= FormatFloat( '0.00', rPrimeraOut + rSegundaOut + rTerceraOut + rDestrioOut + rBotadoOut );


  DAPrincipal.KilosTerceros( sEmpresa, sCentro, sProducto, dFechaini, dFechaFin,
                  rPrimeraTer, rSegundaTer, rTerceraTer, rDestrioTer, rBotadoTer );
  eTercerPrimera.Caption:= FormatFloat( '0.00', rPrimeraTer );
  eTercerSegunda.Caption:= FormatFloat( '0.00', rSegundaTer );
  eTercerTercera.Caption:= FormatFloat( '0.00', rTerceraTer );
  eTercerDestrio.Caption:= FormatFloat( '0.00', rDestrioTer );
  eTercerBotado.Caption:= FormatFloat( '0.00', rBotadoTer );
  eTercerTotal.Caption:= FormatFloat( '0.00', rPrimeraTer + rSegundaTer + rTerceraTer + rDestrioTer + rBotadoTer );

  if rPrimeraOut >= ( rPrimeraIn - rPrimeraTer ) then
    rPrimera := rPrimeraIn - rPrimeraTer
  else
    rPrimera := rPrimeraOut;
  if rSegundaOut >= ( rSegundaIn - rSegundaTer )  then
    rSegunda := rSegundaIn - rSegundaTer
  else
    rSegunda := rSegundaOut;
  rTercera := 0;
  rDestrio := 0;
  rBotado := 0;
   
{
  if rTerceraOut >= ( rTerceraIn - rTerceraTer ) then
    rTercera := rTerceraIn - rTerceraTer
  else
    rTercera := rTerceraOut;
  if rDestrioOut > ( rDestrioIn - rDestrioTer ) then
    rDestrio := ( rDestrioIn - rDestrioTer )
  else
    rDestrio := rDestrioOut;
  if rBotadoOut > ( rBotadoIn - rBotadoTer ) then
    rBotado := ( rBotadoIn - rBotadoTer )
  else
    rBotado := rBotadoOut;
}
  ePrimera.Text:= FormatFloat( '#,##0.00', rPrimera );
  eSegunda.Text:= FormatFloat( '#,##0.00', rSegunda );
  eTercera.Text:= FormatFloat( '#,##0.00', rTercera );
  eDestrio.Text:= FormatFloat( '#,##0.00', rDestrio );
  eBotado.Text:= FormatFloat( '#,##0.00', rBotado );
  eTotal.Caption:= FormatFloat( '#,##0.00', rPrimera + rSegunda + rTercera + rDestrio );
end;

procedure TFAPrincipal.cbPrimeroClick(Sender: TObject);
var dFecha: TDateTime;
    iAnyo, iMes, iDia: word;
begin
  if TryStrToDate( eFecha.Text, dFecha ) then
  begin
    DecodeDate( dFecha, iAnyo, iMes, iDia );
    dFechaIni := dFecha;
    txtFechaIni.Caption:= eFecha.Text;
    sFechaIni := eFecha.Text;

    dFechaFin := EncodeDate(iAnyo, 12, 31);
    txtFechaFin.Caption:= DateToStr( dFechaFin );
    sFechaFin := txtFechaFin.Caption;
  end
  else
  begin
    iAnyo:= 0;
    iMes:= 0;
    iDia := 0;
    txtFechaIni.Caption:= '';
    txtFechaFin.Caption:= '';

    sFechaIni:= '';
    sFechaFin:= '';
  end;
end;

procedure TFAPrincipal.cbSegundoClick(Sender: TObject);
var dFecha: TDateTime;
    iAnyo, iMes, iDia: word;
begin
  if TryStrToDate( eFecha.Text, dFecha ) then
  begin
    DecodeDate( dFecha, iAnyo, iMes, iDia );
    dFechaIni := EncodeDate(iAnyo+1, 1, 1);
    txtFechaIni.Caption:= DateToStr(dFechaIni);
    sFechaIni := txtFechaIni.Caption;

    dFechaFin := EncodeDate(iAnyo+1, 6, 30);
    txtFechaFin.Caption:= DateToStr( dFechaFin );
    sFechaFin := txtFechaFin.Caption;
  end
  else
  begin
    iAnyo:= 0;
    iMes:= 0;
    iDia := 0;
    txtFechaIni.Caption:= '';
    txtFechaFin.Caption:= '';

    sFechaIni:= '';
    sFechaFin:= '';
  end;
end;

procedure TFAPrincipal.cbSemestresClick(Sender: TObject);
var dFecha: TDateTime;
    iAnyo, iMes, iDia: word;
begin
  if cbSemestres.ItemIndex = 0 then
  begin
    if TryStrToDate( eFecha.Text, dFecha ) then
    begin
      DecodeDate( dFecha, iAnyo, iMes, iDia );
      dFechaIni := EncodeDate(iAnyo, 7,1);
      txtFechaIni.Caption:= DateToStr(dFechaIni);
      sFechaIni := txtFechaIni.Caption;

      dFechaFin := EncodeDate(iAnyo, 12, 31);
      txtFechaFin.Caption:= DateToStr( dFechaFin );
      sFechaFin := txtFechaFin.Caption;
    end
    else
    begin
      iAnyo:= 0;
      iMes:= 0;
      iDia := 0;
      txtFechaIni.Caption:= '';
      txtFechaFin.Caption:= '';

      sFechaIni:= '';
      sFechaFin:= '';
    end;
  end
  else if cbSemestres.ItemIndex = 1 then
  begin
    if TryStrToDate( eFecha.Text, dFecha ) then
    begin
      DecodeDate( dFecha, iAnyo, iMes, iDia );
      dFechaIni := EncodeDate(iAnyo+1, 1, 1);
      txtFechaIni.Caption:= DateToStr(dFechaIni);
      sFechaIni := txtFechaIni.Caption;

      dFechaFin := EncodeDate(iAnyo+1, 6, 30);
      txtFechaFin.Caption:= DateToStr( dFechaFin );
      sFechaFin := txtFechaFin.Caption;
      cbSemestres.ItemIndex := 2;
    end
    else
    begin
      iAnyo:= 0;
      iMes:= 0;
      iDia := 0;
      txtFechaIni.Caption:= '';
      txtFechaFin.Caption:= '';

      sFechaIni:= '';
      sFechaFin:= '';
      cbSemestres.ItemIndex := 2;
    end;
  end
  else
  begin
    iAnyo:= 0;
    iMes:= 0;
    iDia := 0;
    txtFechaIni.Caption:= '';
    txtFechaFin.Caption:= '';

    sFechaIni:= '';
    sFechaFin:= '';
    cbSemestres.ItemIndex := 2;
  end;

end;

procedure TFAPrincipal.btnVolverAProductoClick(Sender: TObject);
begin
  eCosecheros.Text:= '';
  txtCosecheros.Caption:= '';
  btnIrACosecheros.Enabled:= True;
  btnVolverAEmpresa.Enabled:= True;
  pProducto.Enabled:= True;
  eProducto.SetFocus;

  pCosechero.Enabled:= False;
  btnIrAKilos.Enabled:= False;
  btnVolverAProducto.Enabled:= False;
end;

procedure TFAPrincipal.btnBorrarClick(Sender: TObject);
begin
  case MessageDlg('¿Desea BORRAR los datos de asignacion?', mtInformation, [mbNo,mbYes],0) of
  mrNo:
    exit;
  mrYes:
    begin
    DPAsignacionTerceros.BorrarDatosAsignados(sEmpresa, sCentro, sProducto, dFechaIni, dFechaFin) ;
    btnCancelarClick(Self);
    end;
  end;

end;

procedure TFAPrincipal.btnAplicarClick(Sender: TObject);
var
  rKilos: real;
  rPrimera: integer;
  bFlag: boolean;
  sValor : string;
begin
  bFlag:= False;
  //****************************************************************************
  //Asignar kilos primera

//  rPrimera := StrToFloat( StringReplace( eInPrimera.Caption, ',', '', [rfReplaceAll] ) );
//  sValor := '7680';
//  rPrimera := StrToInt(sValor);
  ePrimera.Text :=  FloattoStr( StrToFloat( eInPrimera.Caption ) - StrToFloatDef(eTercerPrimera.Caption, 0) ) ;
  if StrToFloatDef( ePrimera.Text, 0.00 ) > StrToFloatDef( eOutPrimera.Caption, 0.00 ) then
  begin
    if not bFlag then
    begin
      ShowMessage('Como máximo se puede asignar el número máximo de kilos de salida.');
      bFlag:= True;
    end;
    rKilos:= StrToFloatDef( eOutPrimera.Caption, 0 );
  end
  else
  begin
    rKilos:= StrToFloatDef( ePrimera.Text, 0 );
  end;
  rKilos:= rKilos - StrToFloatDef( eTercerPrimera.Caption, 0 );
  if rKilos > 0 then
    DPAsignacionTerceros.AsignarKilosTerceros( sEmpresa, sCentro, sProducto, '1', txtCosecheros.Caption, dFechaIni, dFechaFin, rKilos )
  else
  begin
    if not bFlag then
    begin
      ShowMessage('ATENCION! No se pueden asignar kilos de primera.');
      bFlag:= True;
    end;
  end;


  //****************************************************************************
  //Asignar kilos segunda
  eSegunda.Text :=  FloattoStr( StrToFloat( eInSegunda.Caption ) - StrToFloatDef(eTercerSegunda.Caption, 0) ) ;
  if StrToFloatDef( eSegunda.Text, 0 ) > StrToFloatDef( eOutSegunda.Caption, 0 ) then
  begin
    if not bFlag then
    begin
      ShowMessage('Como máximo se puede asignar el número máximo de kilos de salida.');
      bFlag:= True;
    end;
    rKilos:= StrToFloatDef( eOutSegunda.Caption, 0 );
  end
  else
  begin
    rKilos:= StrToFloatDef( eSegunda.Text, 0 );
  end;
  rKilos:= rKilos - StrToFloatDef( eTercerSegunda.Caption, 0 );
  if rKilos > 0 then
    DPAsignacionTerceros.AsignarKilosTerceros( sEmpresa, sCentro, sProducto, '2', txtCosecheros.Caption, dFechaIni, dFechaFin, rKilos )
  else
  begin
    if not bFlag then
    begin
      ShowMessage('ATENCION! No se pueden asignar kilos de segunda.');
      bFlag:= True;
    end;
  end;
{

  //****************************************************************************
  //Asignar kilos tercera
  eTercera.Text :=  FloattoStr( StrToFloat( eInTercera.Caption ) - StrToFloatDef(eTercerTercera.Caption, 0) ) ;
  if StrToFloatDef( eTercera.Text, 0 ) > StrToFloatDef( eOutTercera.Caption, 0 ) then
  begin
    if not bFlag then
    begin
      ShowMessage('Como máximo se puede asignar el número máximo de kilos de salida.');
      bFlag:= True;
    end;
    rKilos:= StrToFloatDef( eOutTercera.Caption, 0 )
  end
  else
  begin
    rKilos:= StrToFloatDef( eTercera.Text, 0 );
  end;
  rKilos:= rKilos - StrToFloatDef( eTercerTercera.Caption, 0 );
  if rKilos > 0 then
    DPAsignacionTerceros.AsignarKilosTerceros( sEmpresa, sCentro, sProducto, '3', txtCosecheros.Caption, dFechaIni, dFechaFin, rKilos )
  else
  begin
    if not bFlag then
    begin
      ShowMessage('ATENCION! No se pueden asignar kilos de tercera.');
      bFlag:= True;
    end;
  end;


  //****************************************************************************
  //Asignar kilos destrio
  eDestrio.Text :=  FloattoStr( StrToFloat( eInDestrio.Caption ) - StrToFloatDef(eTercerDestrio.Caption, 0) ) ;
  if StrToFloatDef( eDestrio.Text, 0 ) > StrToFloatDef( eOutDestrio.Caption, 0 ) then
  begin
    if not bFlag then
    begin
      ShowMessage('Como máximo se puede asignar el número máximo de kilos de salida.');
      bFlag:= True;
    end;
    rKilos:= StrToFloatDef( eOutDestrio.Caption, 0 );
  end
  else
  begin
    rKilos:= StrToFloatDef( eDestrio.Text, 0 );
  end;
  rKilos:= rKilos - StrToFloatDef( eTercerDestrio.Caption, 0 );
  if rKilos > 0 then
    DPAsignacionTerceros.AsignarKilosTerceros( sEmpresa, sCentro, sProducto, 'D', txtCosecheros.Caption, dFechaIni, dFechaFin, rKilos )
  else
  begin
    if not bFlag then
    begin
      ShowMessage('ATENCION! No se pueden asignar kilos de destrio.');
      bFlag:= True;
    end;
  end;

  //****************************************************************************
  //Asignar kilos botado
  if StrToFloatDef( eBotado.Text, 0 ) > StrToFloatDef( eOutBotado.Caption, 0 ) then
  begin
    if not bFlag then
    begin
      ShowMessage('Como máximo se puede asignar el número máximo de kilos de salida.');
      //bFlag:= True;
    end;
    rKilos:= StrToFloatDef( eOutBotado.Caption, 0 );
  end
  else
  begin
    rKilos:= StrToFloatDef( eBotado.Text, 0 );
  end;
  rKilos:= rKilos - StrToFloatDef( eTercerBotado.Caption, 0 );
  if rKilos > 0 then
    DPAsignacionTerceros.AsignarKilosTerceros( sEmpresa, sCentro, sProducto, 'B', txtCosecheros.Caption, dFechaIni, dFechaFin, rKilos )
  else
  begin
    if not bFlag then
    begin
      ShowMessage('ATENCION! No se pueden asignar kilos de botado');
      bFlag:= True;
    end;
  end;
 }
  //Recalcular valores tabla
  CalcularKilos;
  ShowMessage(' Proceso terminado correctamente.');
end;

procedure TFAPrincipal.LimpiarCamposKilos;
begin
  eInPrimera.Caption:= '';
  eInSegunda.Caption:= '';
  eInTercera.Caption:= '';
  eInDestrio.Caption:= '';
  eInBotado.Caption:= '';
  eTotal.Caption:= '';

  eOutPrimera.Caption:= '';
  eOutSegunda.Caption:= '';
  eOutTercera.Caption:= '';
  eOutDestrio.Caption:= '';
  eOutBotado.Caption:= '';
  eOutTotal.Caption:= '';

  ePrimera.Text:= '';
  eSegunda.Text:= '';
  eTercera.Text:= '';
  eDestrio.Text:= '';
  eBotado.Text:= '';
  eTotal.Caption:= '';

  eTercerPrimera.Caption:= '';
  eTercerSegunda.Caption:= '';
  eTercerTercera.Caption:= '';
  eTercerDestrio.Caption:= '';
  eTercerBotado.Caption:= '';
  eTercerTotal.Caption:= '';
end;

procedure TFAPrincipal.btnCancelarClick(Sender: TObject);
begin
  LimpiarCamposKilos;
  btnIrAKilos.Enabled:= True;
  btnVolverAProducto.Enabled:= True;
  pCosechero.Enabled:= True;
  eCosecheros.SetFocus;

  btnAplicar.Enabled:= false;
  btnCancelar.Enabled:= false;
  PKilos.Enabled:= false;
end;

procedure TFAPrincipal.eKilosChange(Sender: TObject);
var
  rPrimera, rSegunda, rTercera, rDestrio, rBotado: Integer;
begin
  rPrimera:= StrToIntDef( ePrimera.Text, 0 );
  rSegunda:= StrToIntDef( eSegunda.Text, 0 );
  rTercera:= StrToIntDef( eTercera.Text, 0 );
  rDestrio:= StrToIntDef( eDestrio.Text, 0 );
  rBotado:= StrToIntDef( eBotado.Text, 0 );
  eTotal.Caption:= IntToStr( rPrimera + rSegunda + rTercera + rDestrio + rBotado );
end;

procedure TFAPrincipal.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if pEmpresa.Enabled then
  begin
    if Key = vk_f5 then
    begin
      btnIrAProducto.Click;
    end
    else
    if Key = vk_escape then
    begin
      btnSalir.Click;
    end;
  end
  else
  if pProducto.Enabled then
  begin
    if Key = vk_f5 then
    begin
      btnIrACosecheros.Click;
    end
    else
    if Key = vk_escape then
    begin
      btnVolverAEmpresa.Click;
    end;
  end
  else
  if pCosechero.Enabled then
  begin
    if Key = vk_f5 then
    begin
      btnIrAKilos.Click;
    end
    else
    if Key = vk_escape then
    begin
      btnVolverAProducto.Click;
    end
    else
    if ( Key = vk_add ) or ( Key = Ord('+') ) then
    begin
      btnAddCosechero.Click;
    end
    else
    if Key = Ord('C') then
    begin
      btnAddCosechero.Click;
    end;
  end
  else
  if PKilos.Enabled then
  begin
    if Key = vk_f5 then
    begin
      btnAplicar.Click;
    end
    else
    if Key = vk_escape then
    begin
      btnCancelar.Click;
    end;
  end;
end;

end.
