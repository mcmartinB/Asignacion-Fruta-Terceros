unit CDPAsignacionTerceros;

interface

uses
  SysUtils, Classes, DB, DBTables, Windows, Forms;

type
  TDPAsignacionTerceros = class(TDataModule)
    QKilosSalida: TQuery;
    QEnvase: TQuery;
    QAux: TQuery;
    QKilosSalidaTercero: TQuery;
    QKilosEntrada: TQuery;
    QSalidasTerceros: TQuery;
    QAuxAct: TQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    sEmpresaTerceros: string;
    QPrecioMedio, QAlbFacturado, QAlbDevolucion: TQuery;

    function  SQLPropios( const ACategoria: string ): string;
    function  SQLTerceros( const ACategoria: string ): string;
    procedure AsignarKilos( const AEmpresa, ACentro, AProducto: string;
              const AFechaIni, AFechaFin: TDateTime; const ADestino: string; const AKilos: Real );
    procedure AsignarKilosxEntrada( const AEmpresa, ACentro, AProducto, ACategoria: string;
              const AFechaIni, AFechaFin: TDateTime; const ADestino: string; const AKilos: Real );
    function  SepararKilosLinea( const ADestino: string; const AKilos: Real ): real;
    procedure PreparaQuerys(const ACentro, AProducto, ACategoria: string);
    function  AlbaranFacturado( const AEmpresa: string; const ACentro: String; const AAlbaran: integer; AFecha: string): Boolean;
    function  EsDevolucion( const AEmpresa: string; const ACentro: String; const AAlbaran: integer; AFecha: string): Boolean;
    procedure CalcularPrecioMedioVenta( const AEmpresa, ACentro, AProducto: String; AFechaIni, AFechaFin: TDateTime; var vPMV: currency);
    function ObtenerMaxLineaAlbaran(AEmpresa, ACentro, AAlbaran, AFecha: String): integer;
    procedure ActualizarSalidas ( const ACategoria, ADestino: string; AKilosParaAsignar: real);
    function BuscarKilosAsignadosAlb ( const AEmpresa, ACentro, AAlbaran, AFecha, AProducto, ACategoria: string; ALinea: Integer ): real;
    procedure InsertarSalidasTerceros(const QSalidas: TQuery; const ACategoria, ADestino: string; const AKilosParaAsignar: currency);
    procedure BorrarTercero (const AEmpresa, ACentro, AProducto: String; const AFechaIni, AFechaFin: TDateTime);
    procedure QuitarTerceroSalidas (const AEmpresa, ACentro, AProducto: String; const AFechaIni, AFechaFin: TDateTime);

    function AbrirTransaccion(DB: TDataBase): boolean;
    procedure AceptarTransaccion(DB: TDataBase);
    procedure CancelarTransaccion(DB: TDataBase);
    function SQLEntrada(const AEmpresa, ACentro, AProducto, ACosechero: string): string;
    function ObtenerLineaAlbaran ( const AEmpresa, ACentro: String; const AFecha: TDateTime; const AAlbaran, AIdLinea: integer): integer;


  public
    { Public declarations }
    procedure AsignarKilosTerceros( const AEmpresa, ACentro, AProducto, ACategoria, ACosechero: string;
              const AFechaIni, AFechaFin: TDateTime; const AKilos: Real );
    procedure BorrarDatosAsignados(const AEmpresa, ACentro, AProducto: String; const AFechaIni, AFechaFin: TDateTime);
  end;


var
  DPAsignacionTerceros: TDPAsignacionTerceros;

implementation

{$R *.dfm}

uses Dialogs, CDAPrincipal, Math, bMath;

function TDPAsignacionTerceros.SQLPropios( const ACategoria: string ): string;
begin
  result:= ' select  * ';
  result:= result + ' from frf_salidas_l ' + #13 + #10;
  result:= result + ' where empresa_sl = :empresa ' + #13 + #10;
  result:= result + ' and centro_salida_sl = :centro ' + #13 + #10;
  result:= result + ' and fecha_sl between :fechaini and :fechafin ' + #13 + #10;
  result:= result + ' and producto_sl = :producto ' + #13 + #10;
  if ACategoria = 'D' then
  begin
    result:= result + ' and (categoria_sl = ''2B'' or  categoria_sl = ''3B'') ' + #13 + #10;
  end
  else
  begin
    result:= result + ' and categoria_sl = ' + QuotedStr( ACategoria ) + ' ' + #13 + #10;
  end;
//  result:= result + ' and emp_procedencia_sl = :empresa or emp_procedencia_sl is null ' + #13 + #10;
//  result := result + ' and (importe_neto_sl/kilos_sl) between :pmvdesde and :pmvhasta '  + #13 + #10;
  result := result + ' and kilos_sl <> 0 ' + #13 + #10;
  result:= result + ' order by fecha_sl, id_linea_albaran_sl ';
end;

function TDPAsignacionTerceros.SQLTerceros( const ACategoria: string ): string;
begin
  result:= ' select * ';
  result:= result + ' from frf_salidas_l ' + #13 + #10;
  result:= result + ' where empresa_sl = :empresa ' + #13 + #10;
  result:= result + ' and centro_salida_sl = :centro ' + #13 + #10;
  result:= result + ' and fecha_sl between :fechaini and :fechafin ' + #13 + #10;
  result:= result + ' and producto_sl = :producto ' + #13 + #10;
  if ACategoria = 'D' then
  begin
    result:= result + ' and categoria_sl in (''2B'',''3B'') ' + #13 + #10;
  end
  else
  begin
    result:= result + ' and categoria_sl = ' + QuotedStr( ACategoria ) + ' ' + #13 + #10;
  end;
  result:= result + ' and emp_procedencia_sl = ' + QuotedStr( sEmpresaTerceros ) + '  ' + #13 + #10;
  result:= result + ' order by fecha_sl desc ';
end;

function TDPAsignacionTerceros.SQLEntrada( const AEmpresa, ACentro, AProducto, ACosechero: string): string;
begin

  if ((DAPrincipal.EsAgrupacionTomate(AProducto)) and (ACentro = '1')) or
     ((AProducto = 'CAL') and (ACentro = '1')) then
  begin
    result:= ' select empresa_e, centro_e, numero_entrada_e, fecha_e, cosechero_e, producto_e,          ' +
             '        round( sum( ( porcen_primera_e * total_kgs_e2l ) / 100 ), 2)  primera,            ' +
             '                round( sum( ( porcen_segunda_e * total_kgs_e2l ) / 100 ), 2) segunda,     ' +
             '                round( sum( ( porcen_tercera_e * total_kgs_e2l ) / 100 ), 2) tercera,     ' +
             '                round( sum( ( porcen_destrio_e * total_kgs_e2l ) / 100 ), 2) destrio,     ' +
             '                round( sum( ( aporcen_merma_e * total_kgs_e2l ) / 100 ), 2) merma         ';
    result:= result + '  from frf_entradas2_l, frf_escandallo ';
    result:= result + ' where empresa_e2l = :empresa ';
    result:= result + '   and centro_e2l in (:centro,6) '; //= :centro '; Se buscan compras en centro 1 - los llanos y 6 - Tenerife. Luego se asignaran ventas del centro 1
    result:= result + '   and fecha_e2l between :fechaini and :fechafin ';
    result:= result + '   and producto_e2l = :producto ';

    if Trim(ACosechero) <> '' then
    result:= result + '   and cosechero_e2l in ( ' + ACosechero + '  ) ';

    result:= result + '   and empresa_e = empresa_e2l ';
    result:= result + '   and centro_e = centro_e2l ';
    result:= result + '   and numero_entrada_e = numero_entrada_e2l ';
    result:= result + '   and fecha_e = fecha_e2l ';
    result:= result + '   and producto_e = producto_e2l';
    result:= result + '   and cosechero_e = cosechero_e2l ';
  end;
end;


procedure TDPAsignacionTerceros.DataModuleCreate(Sender: TObject);
begin
  sEmpresaTerceros:= '501';

  with QEnvase do
  begin
    SQL.Clear;
    SQL.Add( ' select peso_variable_e, peso_neto_e, unidades_e ');
    SQL.Add( ' from frf_envases ');
    SQL.Add( ' where envase_e = :envase ');
    SQL.Add( ' and producto_e = :producto ');

    //Prepare;
  end;

  with QSalidasTerceros do
  begin
    SQL.Clear;
    SQL.Add(' select * ');
    SQL.Add('   from frf_salidas_terceros ');
    SQl.Add('  where envase_st = ""       ');
  end;
  QSalidasTerceros.Open;

end;

procedure TDPAsignacionTerceros.DataModuleDestroy(Sender: TObject);
  procedure Desprepara( var VQuery: TQuery );
  begin
    VQuery.Cancel;
    VQuery.Close;
    if VQuery.Prepared then
      VQuery.UnPrepare;
  end;
begin
  //Desprepara( QEnvase );
  QSalidasTerceros.Close;
end;

procedure TDPAsignacionTerceros.PreparaQuerys(const ACentro, AProducto, ACategoria: string);
begin
  QPrecioMedio := TQuery.Create(Self);
  with QPrecioMedio do
  begin
    DataBaseName := 'DBPrincipal';
    SQL.Clear;
    SQL.Add(' select sum(CASE when kilos_sl = 0 then 0 else importe_neto_sl/kilos_sl END)/count(*) precio_medio ');
    SQL.Add('   from frf_salidas_l ');
    SQL.Add('  where empresa_sl = :empresa ');
    SQL.Add('    and centro_salida_sl = :centro  ');
    SQL.Add('    and fecha_sl between :fechaini and :fechafin ');
    SQL.Add('    and producto_sl = :producto ');
    SQL.Add('    and categoria_sl = ' + QuotedStr( ACategoria )  );

    Prepare;
  end;

  QAlbFacturado := TQuery.Create(Self);
  with QAlbFacturado do
  begin
    DataBaseName := 'DBPrincipal';
    SQL.Clear;
    SQL.Add(' select n_factura_sc from frf_salidas_c ');
    SQL.Add('  where empresa_sc = :empresa ');
    SQL.Add('    and centro_salida_sc = :centro ');
    SQL.Add('    and n_albaran_sc = :albaran ');
    SQL.Add('    and fecha_sc = :fecha ');

    Prepare;
  end;

  QAlbDevolucion := TQuery.Create(Self);
  with QAlbDevolucion do
  begin
    DataBaseName := 'DBPrincipal';
    SQL.Clear;
    SQL.Add(' select * from frf_salidas_c ');
    SQL.Add('  where empresa_sc = :empresa ');
    SQL.Add('    and centro_salida_sc = :centro ');
    SQL.Add('    and n_albaran_sc = :albaran ');
    SQL.Add('    and fecha_sc = :fecha ');
    SQL.Add('    and es_transito_sc = 2 ');         //Tipo Salida: Devolucion

    Prepare;
  end;

  QKilosEntrada := TQuery.Create(Self);
  if ((DAPrincipal.EsAgrupacionTomate(AProducto)) and (ACentro = '1')) or
     ((AProducto = 'CAL') and (ACentro = '1')) then
  begin
    with QKilosEntrada do
    begin
      DataBaseName := 'DBPrincipal';
      SQL.Clear;
      SQL.Add(' select  empresa_e, centro_e, numero_entrada_e, fecha_e, cosechero_e, producto_e,    ');
      SQL.Add(' 	round( sum( ( porcen_primera_e * total_kgs_e2l ) / 100 ), 2)  primera,            ');
      SQL.Add('         round( sum( ( porcen_segunda_e * total_kgs_e2l ) / 100 ), 2) segunda,       ');
      SQL.Add('         round( sum( ( porcen_tercera_e * total_kgs_e2l ) / 100 ), 2) tercera,       ');
      SQL.Add('         round( sum( ( porcen_destrio_e * total_kgs_e2l ) / 100 ), 2) destrio,       ');
      SQL.Add('         round( sum( ( aporcen_merma_e * total_kgs_e2l ) / 100 ), 2) merma           ');
      SQL.Add(' from frf_entradas2_l, frf_escandallo                                                ');
      SQL.Add(' where empresa_e2l = :empresa                                                        ');
      SQL.Add(' and centro_e2l in (:centro, 6)                                                      ');   //= :centro                                                            ');
      SQL.Add(' and fecha_e2l between :fechaini and :fechafin                                       ');
      SQL.Add(' and producto_e2l = :producto                                                        ');

      SQL.Add(' and cosechero_e2l in ( :cosechero)                                                  ');

      SQL.Add(' and empresa_e = empresa_e2l                                                         ');
      SQL.Add(' and centro_e = centro_e2l                                                           ');
      SQL.Add(' and numero_entrada_e = numero_entrada_e2l                                           ');
      SQL.Add(' and fecha_e = fecha_e2l                                                             ');
      SQL.Add(' and producto_e = producto_e2l                                                       ');
      SQL.Add(' and cosechero_e = cosechero_e2l                                                     ');
      SQL.Add(' group by empresa_e, centro_e, numero_entrada_e, fecha_e, cosechero_e, producto_e    ');
      SQL.Add(' order by empresa_e, centro_e, producto_e, fecha_e, numero_entrada_e                 ');
    end
  end
  else if ACentro = '3' then
  begin
    with QKilosEntrada do
    begin
      DataBaseName := 'DBPrincipal';
      SQL.Clear;
      SQL.Add(' select                                   ');
      SQL.Add('                               0 primera, ');
      SQL.Add('                               0 segunda, ');
      SQL.Add('       round(sum(total_kgs_e2l)) tercera, ');
      SQL.Add('                               0 destrio, ');
      SQL.Add('                               0 merma    ');
      SQL.Add('  from frf_entradas2_l                    ');
      SQL.Add('  where empresa_e2l = :empresa            ');
      SQL.Add('    and centro_e2l = :centro              ');
      SQL.Add('    and fecha_e2l between :fechaini and :fechafin ');
      SQL.Add('    and producto_e2l = :producto ');

      SQL.Add(' and cosechero_e2l in ( :cosechero ) ');
    end;
  end
  else
  begin
    with QKilosEntrada do
    begin
      DataBaseName := 'DBPrincipal';
      SQL.Clear;
      SQL.Clear;
      SQL.Add(' select ');
      SQL.Add('       round(sum(total_kgs_e2l)) primera, ');
      SQL.Add('                               0 segunda, ');
      SQL.Add('                               0 tercera, ');
      SQL.Add('                               0 destrio, ');
      SQL.Add('                               0 merma    ');
      SQL.Add('  from frf_entradas2_l                    ');
      SQL.Add('  where empresa_e2l = :empresa            ');
      SQL.Add('    and centro_e2l = :centro              ');
      SQL.Add('    and fecha_e2l between :fechaini and :fechafin ');
      SQL.Add('    and producto_e2l = :producto ');

      SQL.Add(' and cosechero_e2l in ( :cosechero ) ');
    end;
  end;

  QKilosEntrada.Prepare;

end;

procedure TDPAsignacionTerceros.AsignarKilosTerceros( const AEmpresa, ACentro, AProducto, ACategoria, ACosechero: string;
              const AFechaIni, AFechaFin: TDateTime; const AKilos: Real );
begin
  PreparaQuerys(ACentro, AProducto, ACategoria);
  if AKilos < 0 then
  begin
    QKilosSalida.SQL.Clear;
    QKilosSalida.SQL.Add( SQLTerceros( ACategoria ) );
    AsignarKilos( AEmpresa, ACentro, AProducto, AFechaIni, AFechaFin, AEmpresa, Abs( AKilos ) );
  end
  else
  if AKilos > 0 then
  begin
    QKilosSalida.SQL.Clear;
    QKilosSalida.SQL.Add( SQLPropios( ACategoria ) );

    QKilosEntrada.Close;
    QKilosEntrada.ParamByName('empresa').AsString := AEmpresa;
    QKilosEntrada.ParamByName('centro').AsString := ACentro;
    QKilosEntrada.ParamByName('fechaini').AsDateTime := AFechaIni;
    QKilosEntrada.ParamByName('fechafin').AsDateTime := AFechaFin;
    QKilosEntrada.ParamByName('producto').AsString := AProducto;
    QKilosEntrada.ParamByName('cosechero').AsString := ACosechero;
    QKilosEntrada.Open;
    AsignarKilosxEntrada( AEmpresa, ACentro, AProducto, ACategoria, AFechaIni, AFechaFin, sEmpresaTerceros, AKilos );
  end;
end;

procedure TDPAsignacionTerceros.CalcularPrecioMedioVenta(const AEmpresa, ACentro, AProducto: String; AFechaIni, AFechaFin: TDateTime;var vPMV: currency);
begin
  with QPrecioMedio do
  begin
    if Active then
      Close;

    ParamByName('empresa').AsString := AEmpresa;
    ParamByName('centro').AsString := ACentro;
    ParamByName('fechaini').AsDateTime := AFechaIni;
    ParamByName('fechafin').AsDateTime := AFechaFin;
    ParamByName('producto').AsString := AProducto;

    Open;

    vPMV := FieldByName('precio_medio').AsFloat;
  end;
end;

function TDPAsignacionTerceros.AlbaranFacturado(const AEmpresa, ACentro: String; const AAlbaran: integer; AFecha: string): Boolean;
begin
  with QAlbFacturado do
  begin
    if Active then
    Close;

    ParamByName('empresa').AsString := AEmpresa;
    ParamByName('centro').AsString := ACentro;
    ParamByName('albaran').AsInteger := AAlbaran;
    ParamByName('fecha').AsString := AFecha;
    Open;

    Result := (FieldByName('n_factura_sc').AsString <> '');
  end;
end;

function TDPAsignacionTerceros.EsDevolucion(const AEmpresa, ACentro: String;
  const AAlbaran: integer; AFecha: string): Boolean;
begin
  with QAlbDevolucion do
  begin
    if Active then
    Close;

    ParamByName('empresa').AsString := AEmpresa;
    ParamByName('centro').AsString := ACentro;
    ParamByName('albaran').AsInteger := AAlbaran;
    ParamByName('fecha').AsString := AFecha;
    Open;

    Result := not IsEmpty;
  end;
end;

function TDPAsignacionTerceros.ObtenerLineaAlbaran ( const AEmpresa, ACentro: String; const AFecha:TDateTime; const AAlbaran, AIdLinea: integer): integer;
begin
  with QAux do
  begin
    SQL.Clear;
    SQL.Add(' select nvl(max(id_linea_tercero_st), 0) max_linea     ');
    SQL.Add('   from frf_salidas_terceros             ');
    SQL.Add('  where empresa_st = :empresa            ');
    SQL.Add('    and centro_salida_st = :centro       ');
    SQL.Add('    and n_albaran_st = :albaran          ');
    SQL.Add('    and fecha_st = :fecha                ');
    SQL.Add('    and id_linea_albaran_st = :id_linea  ');

    ParamByName('empresa').AsString := AEmpresa;
    ParamByName('centro').AsString := ACentro;
    ParamByName('albaran').Asinteger := AAlbaran;
    ParamByName('fecha').AsDateTime := AFecha;
    ParamByName('id_linea').AsInteger := AIdLinea;

    Open;
    result := FieldByName('max_linea').AsInteger + 1;
    Close;
  end;
end;

function TDPAsignacionTerceros.ObtenerMaxLineaAlbaran(AEmpresa, ACentro, AAlbaran, AFecha: String): integer;
begin
  with QAux do
  begin
    if Active then
    Close;

    SQL.Clear;
    SQL.Add(' select max(id_linea_albaran_sl) n_linea from frf_salidas_l ');
    SQL.Add('  where empresa_sl = :empresa                               ');
    SQL.Add('    and centro_salida_sl = :centro                          ');
    SQL.Add('    and n_albaran_sl = :albaran                             ');
    SQL.Add('    and fecha_sl = :fecha                                   ');

    ParamByName('empresa').AsString := AEmpresa;
    ParamByName('centro').AsString := ACentro;
    ParamByName('albaran').AsString := AAlbaran;
    ParamByName('fecha').AsString := AFecha;
    Open;

    Result := FieldByName('n_linea').AsInteger;
  end;
end;

procedure TDPAsignacionTerceros.AsignarKilos( const AEmpresa, ACentro, AProducto: string; const AFechaIni, AFechaFin: TDateTime; const ADestino: string; const AKilos: Real );
var
  rAux, rSep: Real;
  rPMV, rPMVDesde, rPMVHasta: currency;
begin
  rPMV := 0;
  rAux:= AKilos;
  CalcularPrecioMedioVenta(AEmpresa, ACentro, AProducto, AFechaIni, AFechaFin, rPMV);
  rPMVDesde := (rPMV * 70) / 100;   //70% del precio medio de venta
  rPMVHasta := (rPMV * 120) / 100;  //120% del precio medio de venta

  QKilosSalida.ParamByName('empresa').AsString:= AEmpresa;
  QKilosSalida.ParamByName('centro').AsString:= ACentro;
  QKilosSalida.ParamByName('producto').AsString:= AProducto;
  QKilosSalida.ParamByName('fechaini').AsDateTime:= AFechaIni;
  QKilosSalida.ParamByName('fechafin').AsDateTime:= AFechaFin;
  QKilosSalida.ParamByName('pmvdesde').AsFloat:= rPMVDesde;
  QKilosSalida.ParamByName('pmvhasta').AsFloat:= rPMVHasta;
  QKilosSalida.Open;


  if not QKilosSalida.IsEmpty then
  begin
    while rAux > 0 do
    begin
      if ( AlbaranFacturado(QKilosSalida.FieldByName('empresa_sl').AsString, QKilosSalida.FieldByName('centro_salida_sl').AsString,
                            QKilosSalida.FieldByName('n_albaran_sl').AsInteger, QKilosSalida.FieldByName('fecha_sl').AsString) ) and
         ( not EsDevolucion(QKilosSalida.FieldByName('empresa_sl').AsString, QKilosSalida.FieldByName('centro_salida_sl').AsString,
                            QKilosSalida.FieldByName('n_albaran_sl').AsInteger, QKilosSalida.FieldByName('fecha_sl').AsString) )   then
      begin
        if rAux >= QKilosSalida.FieldByName('kilos_sl').AsFloat then
        begin
          QKilosSalida.Edit;
          QKilosSalida.FieldByName('emp_procedencia_sl').AsString:= ADestino;
          QKilosSalida.Post;
          rAux:= rAux - QKilosSalida.FieldByName('kilos_sl').AsFloat;
        end
        else
        begin
          rSep:= SepararKilosLinea( ADestino, rAux );
          if rSep = 0 then
            rAux := 0
          else
            rAux:= rAux - rSep;
        end;
      end;
      QKilosSalida.Next;
    end;
  end;
  QKilosSalida.Close;
end;

procedure TDPAsignacionTerceros.AsignarKilosxEntrada( const AEmpresa, ACentro, AProducto, ACategoria: string; const AFechaIni, AFechaFin: TDateTime; const ADestino: string; const AKilos: Real );
var
  rKilosEntrada,
  rKilosAsignadosAlb, rKilosDisponiblesAlb, rKilosParaAsignar: Real;
  rPMV, rPMVDesde, rPMVHasta: currency;
  dFechaAlbIni, dFechaAlbFin: TDateTime;
begin

  //Recorremos las entradas del cosechero 0 para el producto y entre las fechas.
  while not QKilosEntrada.Eof do
  begin

    dFechaAlbIni := QKilosEntrada.FieldByName('fecha_e').AsDateTime;
    dFechaAlbFin := QKilosEntrada.FieldByName('fecha_e').AsDateTime + 30;
    rPMV := 0;
    if ACategoria = '1' then
      rKilosEntrada:= QKilosEntrada.FieldByName('primera').AsFloat
    else if ACategoria = '2' then
      rKilosEntrada:= QKilosEntrada.FieldByName('segunda').AsFloat
    else if ACategoria = '3' then
      rKilosEntrada:= QKilosEntrada.FieldByName('tercera').AsFloat
    else if (ACategoria = '2B') or (ACategoria = '3B')  then
      rKilosEntrada:= QKilosEntrada.FieldByName('destrio').AsFloat
    else if ACategoria = 'B' then
      rKilosEntrada:= QKilosEntrada.FieldByName('merma').AsFloat
    else
      rKilosEntrada:= 0;

    CalcularPrecioMedioVenta(AEmpresa, ACentro, AProducto, dFechaAlbIni, dFechaAlbFin, rPMV);
    rPMVDesde := (rPMV * 70) / 100;   //70% del precio medio de venta
    rPMVHasta := (rPMV * 120) / 100;  //120% del precio medio de venta

    QKilosSalida.ParamByName('empresa').AsString:= AEmpresa;
    QKilosSalida.ParamByName('centro').AsString:= ACentro;
    QKilosSalida.ParamByName('producto').AsString:= AProducto;
    QKilosSalida.ParamByName('fechaini').AsDateTime:= dFechaAlbIni;
    QKilosSalida.ParamByName('fechafin').AsDateTime:= dFechaAlbFin;  //AFechaIni + 30 dias
//    QKilosSalida.ParamByName('pmvdesde').AsFloat:= rPMVDesde;
//    QKilosSalida.ParamByName('pmvhasta').AsFloat:= rPMVHasta;
    QKilosSalida.Open;


    while (not QKilosSalida.Eof) and (bRoundTo(rKilosEntrada, 2) > 0) do
    begin
      rKilosAsignadosAlb := BuscarKilosAsignadosAlb(QKilosSalida.FieldByName('empresa_sl').AsString, QKilosSalida.FieldByName('centro_salida_sl').AsString,
                                                    QKilosSalida.FieldByName('n_albaran_sl').AsString, QKilosSalida.FieldByName('fecha_sl').AsString,
                                                    QKilosSalida.FieldByName('producto_sl').AsString, QKilosSalida.FieldByName('categoria_sl').AsString,
                                                    QKilosSalida.FieldByName('id_linea_albaran_sl').AsInteger);
      rKilosDisponiblesAlb := bRoundTo(QKilosSalida.FieldByName('kilos_sl').AsFloat - rKilosAsignadosAlb, 2);
      if rKilosDisponiblesAlb > 0 then
      begin

        if ( AlbaranFacturado(QKilosSalida.FieldByName('empresa_sl').AsString, QKilosSalida.FieldByName('centro_salida_sl').AsString,
                              QKilosSalida.FieldByName('n_albaran_sl').AsInteger, QKilosSalida.FieldByName('fecha_sl').AsString) ) and
           ( not EsDevolucion(QKilosSalida.FieldByName('empresa_sl').AsString, QKilosSalida.FieldByName('centro_salida_sl').AsString,
                              QKilosSalida.FieldByName('n_albaran_sl').AsInteger, QKilosSalida.FieldByName('fecha_sl').AsString) )   then
        begin

          if rKilosEntrada >= rKilosDisponiblesAlb then
            rKilosParaAsignar := rKilosDisponiblesAlb
          else
            rKilosParaAsignar := rKilosEntrada;

          ActualizarSalidas(ACategoria, ADestino, rKilosParaAsignar);
          rKilosEntrada := rKilosEntrada - rKilosParaAsignar;

        end;
      end;
      QKilosSalida.Next;
    end;
    QKilosSalida.Close;

    QKilosEntrada.Next;
  end;
end;

function TDPAsignacionTerceros.AbrirTransaccion(DB: TDataBase): boolean;
var
  T, Tiempo: Cardinal;
  cont: integer;
  flag: boolean;
begin

  cont := 0;
  flag := true;
  while flag do
  begin
        //Abrimos transaccion si podemos
    if DB.InTransaction then
    begin
           //Ya hay una transaccion abierta
      inc(cont);
      if cont = 3 then
      begin
        ShowMessage('En este momento no se puede llevar a cabo la operación seleccionada. ' + #10 + #13 + 'Por favor vuelva a intentarlo mas tarde..');
        AbrirTransaccion := false;
        Exit;
      end;
           //Esperar entre 1 y (1+cont) segundos
      T := GetTickCount;
      Tiempo := cont * 1000 + Random(1000);
      while GetTickCount - T < Tiempo do Application.ProcessMessages;
    end
    else
    begin
      DB.StartTransaction;
      flag := false;
    end;
  end;
  AbrirTransaccion := true;

end;

procedure TDPAsignacionTerceros.AceptarTransaccion(DB: TDataBase);
begin
  if DB.InTransaction then
  begin
    DB.Commit;
  end;
end;

procedure TDPAsignacionTerceros.ActualizarSalidas ( const ACategoria, ADestino: string; AKilosParaAsignar: real);
var sAux: String;
begin
  try
    if not AbrirTransaccion(DAPrincipal.DBPrincipal) then
      raise Exception.Create('Error al abrir transaccion en BD.');

    //Actualizamos Albaran de Venta (Salidas)
    QKilosSalida.Edit;
    QKilosSalida.FieldByName('emp_procedencia_sl').AsString:= ADestino;
    QKilosSalida.Post;
    //Insertamos en frf_salidas_terceros
    InsertarSalidasTerceros(QKilosSalida, ACategoria, ADestino, AKilosParaAsignar);

    AceptarTransaccion(DAPrincipal.DBPrincipal);
    except
    on e: Exception do
    begin
      if DAPrincipal.DBPrincipal.InTransaction then
        CancelarTransaccion(DAPrincipal.DBPrincipal);
      sAux := QKilosSalida.FieldByName('empresa_sl').AsString + ' ' +
              QKilosSalida.FieldByName('centro_salida_sl').AsString + ' ' +
              QKilosSalida.FieldByName('fecha_sl').AsString + ' ' +
              QKilosSalida.FieldByName('n_albaran_sl').AsString;
      ShowMessage( 'ERROR: No se ha podido actualizar el albaran : ' + sAux + #13 + #10 + e.Message);
    end;
  end;
end;

function AbrirTransaccion(DB: TDataBase): Boolean;
var
  T, Tiempo: Cardinal;
  cont: integer;
  flag: boolean;
begin
  cont := 0;
  flag := true;
  while flag do
  begin
        //Abrimos transaccion si podemos
    if DB.InTransaction then
    begin
           //Ya hay una transaccion abierta
      inc(cont);
      if cont = 3 then
      begin
        AbrirTransaccion := false;
        Exit;
      end;
           //Esperar entre 1 y (1+cont) segundos
      T := GetTickCount;
      Tiempo := cont * 1000 + Random(1000);
      while GetTickCount - T < Tiempo do Application.ProcessMessages;
    end
    else
    begin
      DB.StartTransaction;
      flag := false;
    end;
  end;
  AbrirTransaccion := true;
end;

procedure AceptarTransaccion(DB: TDataBase);
begin
  if DB.InTransaction then
  begin
    DB.Commit;
  end;
end;

procedure TDPAsignacionTerceros.CancelarTransaccion(DB: TDataBase);
begin
  if DB.InTransaction then
  begin
    DB.Rollback;
  end;
end;

procedure TDPAsignacionTerceros.BorrarDatosAsignados(const AEmpresa, ACentro, AProducto: String; const AFechaIni, AFechaFin: TDateTime);
var sAux: String;
begin
  try
    if not AbrirTransaccion(DAPrincipal.DBPrincipal) then
      raise Exception.Create('Error al abrir transaccion en BD.');

    BorrarTercero ( AEmpresa, ACentro, AProducto, AFechaini, AFechaFin );
    QuitarTerceroSalidas ( AEmpresa, ACentro, AProducto, AFechaini, AFechaFin );

    AceptarTransaccion(DAPrincipal.DBPrincipal);
    except
    on e: Exception do
    begin
      if DAPrincipal.DBPrincipal.InTransaction then
        CancelarTransaccion(DAPrincipal.DBPrincipal);
      sAux := QKilosSalida.FieldByName('empresa_sl').AsString + ' ' +
              QKilosSalida.FieldByName('centro_salida_sl').AsString + ' ' +
              QKilosSalida.FieldByName('fecha_sl').AsString + ' ' +
              QKilosSalida.FieldByName('n_albaran_sl').AsString;
      ShowMessage( 'ERROR: No se ha podido actualizar el albaran : ' + sAux + #13 + #10 + e.Message);
    end;
  end;
end;

procedure TDPAsignacionTerceros.BorrarTercero(const AEmpresa, ACentro,
  AProducto: String; const AFechaIni, AFechaFin: TDateTime);
begin
  with QAuxAct do
  try
    SQL.Clear;
    SQL.Add(' delete frf_salidas_terceros                              ');
    SQL.Add('  where empresa_st = :empresa                             ');
    SQL.Add('    and centro_salida_st = :centro                        ');
    SQL.Add('    and fecha_st between :fechaini and :fechafin          ');
    SQL.Add('    and producto_st = :producto                           ');

    ParamByName('empresa').AsString := AEmpresa;
    ParamByName('centro').AsString := ACentro;
    ParamByName('fechaini').AsDateTime := AFechaIni;
    ParamByName('fechafin').AsDateTime := AFechaFin;
    ParamByName('producto').AsString := AProducto;
    ExecSQL;

  finally
    Close;
  end;
end;

procedure TDPAsignacionTerceros.QuitarTerceroSalidas(const AEmpresa, ACentro, AProducto: String; const AFechaIni, AFechaFin: TDateTime);
begin
  with QAuxAct do
  try
    SQL.Clear;
    SQL.Add(' update frf_salidas_l set emp_procedencia_sl = empresa_sl ');
    SQL.Add('  where empresa_sl = :empresa                             ');
    SQL.Add('    and centro_salida_sl = :centro                        ');
    SQL.Add('    and fecha_sl between :fechaini and :fechafin          ');
    SQL.Add('    and producto_sl = :producto                           ');
    SQL.Add('    and emp_procedencia_sl <> empresa_sl                  ');

    ParamByName('empresa').AsString := AEmpresa;
    ParamByName('centro').AsString := ACentro;
    ParamByName('fechaini').AsDateTime := AFechaIni;
    ParamByName('fechafin').AsDateTime := AFechaFin;
    ParamByName('producto').AsString := AProducto;
    ExecSQL;

  finally
    Close;
  end;

end;

function TDPAsignacionTerceros.BuscarKilosAsignadosAlb ( const AEmpresa, ACentro, AAlbaran, AFecha, AProducto, ACategoria: string; ALinea: integer ): real;
begin
  with QAux do
  try
    if Active then
      Close;
    SQL.Clear;
    SQL.Add(' select nvl(sum(kilos_st), 0) kilos      ');
    SQL.Add(' from frf_salidas_terceros               ');
    SQL.Add(' where empresa_st = :empresa             ');
    SQL.Add('   and centro_salida_st = :centro        ');
    SQL.Add('   and n_albaran_st = :albaran           ');
    SQL.Add('   and fecha_st = :fecha                 ');
    SQL.Add('   and producto_st = :producto           ');
    SQL.Add('   and categoria_st = :categoria         ');
    SQL.Add('   and id_linea_albaran_st = :idlinea    ');

    ParamByName('empresa').AsString := AEmpresa;
    ParamByName('centro').AsString := ACentro;
    ParamByName('albaran').AsString := AAlbaran;
    ParamByName('fecha').AsString := AFecha;
    ParamByName('producto').AsString := AProducto;
    ParamByName('categoria').AsString := ACategoria;
    ParamByName('idlinea').AsInteger := ALinea;

    Open;
    result := Fieldbyname('kilos').AsFloat;
  finally
    Close;
  end;
end;

procedure TDPAsignacionTerceros.InsertarSalidasTerceros(const QSalidas: TQuery; const ACategoria, ADestino: string; const AKilosParaAsignar: currency);
var rPorcentaje: Real;
begin

  rPorcentaje := AKilosParaAsignar / QSalidas.FieldByName('kilos_sl').AsFloat;
  try
    QSalidasTerceros.Insert;

    QSalidasTerceros.FieldByName('empresa_st').AsString :=  QSalidas.FieldByName('empresa_sl').AsString;
    QSalidasTerceros.FieldByName('centro_salida_st').AsString :=  QSalidas.FieldByName('centro_salida_sl').AsString;
    QSalidasTerceros.FieldByName('n_albaran_st').AsString :=  QSalidas.FieldByName('n_albaran_sl').AsString;
    QSalidasTerceros.FieldByName('fecha_st').AsString :=  QSalidas.FieldByName('fecha_sl').AsString;
    QSalidasTerceros.FieldByName('id_linea_albaran_st').AsInteger :=  QSalidas.FieldByName('id_linea_albaran_sl').AsInteger;
    QSalidasTerceros.FieldByName('producto_st').AsString :=  QSalidas.FieldByName('producto_sl').AsString;
    QSalidasTerceros.FieldByName('envase_st').AsString :=  QSalidas.FieldByName('envase_sl').AsString;
    QSalidasTerceros.FieldByName('categoria_st').AsString :=  QSalidas.FieldByName('categoria_sl').AsString;

    QSalidasTerceros.FieldByName('kilos_st').AsFloat :=  AKilosParaAsignar;
    QSalidasTerceros.FieldByName('cajas_st').Asfloat :=  rPorcentaje * QSalidas.FieldByName('cajas_sl').AsFloat;
    QSalidasTerceros.FieldByName('importe_neto_st').AsFloat :=  rPorcentaje * QSalidas.FieldByName('importe_neto_sl').AsFloat;
    QSalidasTerceros.FieldByName('iva_st').AsFloat :=  rPorcentaje * QSalidas.FieldByName('iva_sl').AsFloat;
    QSalidasTerceros.FieldByName('importe_total_st').AsFloat :=  rPorcentaje * QSalidas.FieldByName('importe_total_sl').AsFloat;

    QSalidasTerceros.FieldByName('emp_procedencia_st').AsString :=  ADestino;

    QSalidasTerceros.FieldByName('empresa_entrada_st').AsString := QKilosEntrada.FieldByName('empresa_e').AsString;
    QSalidasTerceros.FieldByName('centro_entrada_st').AsString := QKilosEntrada.FieldByName('centro_e').AsString;
    QSalidasTerceros.FieldByName('numero_entrada_st').AsInteger := QKilosEntrada.FieldByName('numero_entrada_e').AsInteger;
    QSalidasTerceros.FieldByName('fecha_entrada_st').AsDateTime := QKilosEntrada.FieldByName('fecha_e').AsDateTime;
    QSalidasTerceros.FieldByName('id_linea_tercero_st').AsInteger := ObtenerLineaAlbaran(QSalidas.FieldByName('empresa_sl').AsString, QSalidas.FieldByName('centro_salida_sl').AsString,
                                                                     QSalidas.FieldByName('fecha_sl').AsDateTime, QSalidas.FieldByName('n_albaran_sl').AsInteger, QSalidas.FieldByName('id_linea_albaran_sl').AsInteger );

    QSalidasTerceros.Post;
  except
    raise;
  end;
end;

function TDPAsignacionTerceros.SepararKilosLinea( const ADestino: string; const AKilos: Real ): real;
var
  empresa_sl, centro_salida_sl, centro_origen_sl, producto_sl, envase_sl,
  marca_sl, categoria_sl, calibre_sl, color_sl, unidad_precio_sl, tipo_iva_sl,
  federacion_sl, cliente_sl, emp_procedencia_sl, tipo_palets_sl, comercial_sl: string;
  n_albaran_sl, ref_transitos_sl, n_linea: integer;
  fecha_sl: TDateTime;
  precio_sl, porc_iva_sl: real;

  cajas_1, n_palets_1, cajas_2, n_palets_2: integer;
  kilos_1, importe_neto_1, iva_1, importe_total_1, kilos_2, importe_neto_2, iva_2, importe_total_2: real;

  iUnidades: integer;
  rPesoNetoCaja: real;
  bPesoVariable: boolean;
  rKilos: Real;
begin
(*
  empresa_sl, centro_salida_sl, n_albaran_sl, fecha_sl, centro_origen_sl, producto_sl,
  envase_sl, marca_sl, categoria_sl, calibre_sl, color_sl, ref_transitos_sl,
  precio_sl, unidad_precio_sl, porc_iva_sl, tipo_iva_sl, federacion_sl, cliente_sl,

  cajas_sl, kilos_sl, importe_neto_sl, iva_sl, importe_total_sl, n_palets_sl, emp_procedencia_sl
*)
  result:= 0;

  empresa_sl:= QKilosSalida.FieldByName('empresa_sl').AsString;
  centro_salida_sl:= QKilosSalida.FieldByName('centro_salida_sl').AsString;
  centro_origen_sl:= QKilosSalida.FieldByName('centro_origen_sl').AsString;
  producto_sl:= QKilosSalida.FieldByName('producto_sl').AsString;
  envase_sl:= QKilosSalida.FieldByName('envase_sl').AsString;
  marca_sl:= QKilosSalida.FieldByName('marca_sl').AsString;
  categoria_sl:= QKilosSalida.FieldByName('categoria_sl').AsString;
  calibre_sl:= QKilosSalida.FieldByName('calibre_sl').AsString;
  color_sl:= QKilosSalida.FieldByName('color_sl').AsString;
  unidad_precio_sl:= QKilosSalida.FieldByName('unidad_precio_sl').AsString;
  tipo_iva_sl:= QKilosSalida.FieldByName('tipo_iva_sl').AsString;
  federacion_sl:= QKilosSalida.FieldByName('federacion_sl').AsString;
  cliente_sl:= QKilosSalida.FieldByName('cliente_sl').AsString;
  n_albaran_sl:= QKilosSalida.FieldByName('n_albaran_sl').AsInteger;
//  if not QKilosSalida.FieldByName('ref_transitos_sl').IsNull then
//    ref_transitos_sl:= QKilosSalida.FieldByName('ref_transitos_sl').AsInteger;
  fecha_sl:= QKilosSalida.FieldByName('fecha_sl').AsDateTime;
  precio_sl:= QKilosSalida.FieldByName('precio_sl').AsFloat;
  porc_iva_sl:= QKilosSalida.FieldByName('porc_iva_sl').AsFloat;
  emp_procedencia_sl:= QKilosSalida.FieldByName('emp_procedencia_sl').AsString;
  tipo_palets_sl:= QKilosSalida.FieldByName('tipo_palets_sl').AsString;
  comercial_sl:= QKilosSalida.FieldByName('comercial_sl').AsString;


  QEnvase.ParamByName('envase').AsString:= QKilosSalida.FieldByName('envase_sl').AsString;
  QEnvase.ParamByName('producto').AsString:= QKilosSalida.FieldByName('producto_sl').AsString;
  QEnvase.Open;
  if not QEnvase.IsEmpty then
  begin
    iUnidades:= QEnvase.FieldByName('unidades_e').AsInteger;
    rPesoNetoCaja:= QEnvase.FieldByName('peso_neto_e').AsFloat;
    if rPesoNetoCaja = 0 then
    begin
      if QKilosSalida.FieldByName('cajas_sl').AsFloat > 0 then
       begin
        rPesoNetoCaja:= SimpleRoundTo( QKilosSalida.FieldByName('kilos_sl').AsFloat / QKilosSalida.FieldByName('cajas_sl').AsFloat, -2 );
      end
      else
      begin
        rPesoNetoCaja:= 0;
      end;
    end;
    bPesoVariable:= QEnvase.FieldByName('peso_variable_e').AsInteger <> 0;
  end
  else
  begin
    iUnidades:= 0;
    if QKilosSalida.FieldByName('cajas_sl').AsFloat > 0 then
    begin
      rPesoNetoCaja:= SimpleRoundTo( QKilosSalida.FieldByName('kilos_sl').AsFloat / QKilosSalida.FieldByName('cajas_sl').AsFloat, -2 );
    end
    else
    begin
      rPesoNetoCaja:= 0;
    end;
    if rPesoNetoCaja = 0 then
    begin
      bPesoVariable:= True;
    end
    else
    begin
      bPesoVariable:= ( rPesoNetoCaja - Trunc( rPesoNetoCaja ) ) <> 0;
    end;
  end;
  QEnvase.Close;
  if not bPesoVariable then
  begin
    rKilos:= SimpleRoundTo( Trunc( AKilos / rPesoNetoCaja ) * rPesoNetoCaja, -2 );
  end
  else
  begin
    rKilos:= AKilos;
  end;


  kilos_1:= rKilos;
  kilos_2:= QKilosSalida.FieldByName('kilos_sl').AsFloat - rKilos;

  if rPesoNetoCaja > 0 then
  begin
    cajas_1:= Trunc( SimpleRoundTo( ( rKilos / rPesoNetoCaja ), 0 ) );
  end
  else
  begin
    cajas_1:= 0;
  end;
  cajas_2:= QKilosSalida.FieldByName('cajas_sl').AsInteger - cajas_1;

  if QKilosSalida.FieldByName('kilos_sl').AsFloat > 0 then
  begin
    n_palets_1:= Trunc( SimpleRoundTo( ( rKilos * QKilosSalida.FieldByName('n_palets_sl').AsFloat ) / QKilosSalida.FieldByName('kilos_sl').AsFloat, 0 ) );
  end
  else
  begin
    n_palets_1:= 0;
  end;
  n_palets_2:= QKilosSalida.FieldByName('n_palets_sl').AsInteger - n_palets_1;

  if Copy( QKilosSalida.FieldByName('unidad_precio_sl').AsString, 1, 1 ) = 'C' then
  begin
    importe_neto_1:= QKilosSalida.FieldByName('precio_sl').AsFloat * cajas_1;
  end
  else
  if Copy( QKilosSalida.FieldByName('unidad_precio_sl').AsString, 1, 1 ) = 'U' then
  begin
    if iUnidades > 0 then
    begin
      importe_neto_1:= SimpleRoundTo( QKilosSalida.FieldByName('precio_sl').AsFloat * cajas_1 * iUnidades, -2 );
    end
    else
    begin
      importe_neto_1:= SimpleRoundTo( ( rKilos * QKilosSalida.FieldByName('importe_neto_sl').AsFloat ) / QKilosSalida.FieldByName('kilos_sl').AsFloat, -2 );
    end;
  end
  else
  begin
    importe_neto_1:= QKilosSalida.FieldByName('precio_sl').AsFloat * kilos_1;
  end;

  importe_neto_1:= SimpleRoundTo( ( rKilos * QKilosSalida.FieldByName('importe_neto_sl').AsFloat ) / QKilosSalida.FieldByName('kilos_sl').AsFloat, -2 );
  importe_neto_2:= QKilosSalida.FieldByName('importe_neto_sl').AsFloat - importe_neto_1;

  iva_1:= SimpleRoundTo( ( importe_neto_1 * QKilosSalida.FieldByName('porc_iva_sl').AsFloat ) / 100, -2 );
  iva_2:= QKilosSalida.FieldByName('iva_sl').AsFloat - iva_1;

  importe_total_1:= importe_neto_1 + iva_1;
  importe_total_2:= QKilosSalida.FieldByName('importe_total_sl').AsFloat - importe_total_1;

//  n_linea := QKilosSalida.FieldByName('id_linea_albaran_sl').AsInteger;
  n_linea := ObtenerMaxLineaAlbaran (QKilosSalida.FieldByName('empresa_sl').AsString, QKilosSalida.FieldByName('centro_salida_sl').AsString,
                                     QKilosSalida.FieldByName('n_albaran_sl').AsString, QKilosSalida.FieldByName('fecha_sl').AsString);
  if kilos_1 <> 0  then
  begin
    if not QKilosSalida.Database.InTransaction then
    begin
      QKilosSalida.Database.StartTransaction;
      try
        with QKilosSalida do
        begin
          Edit;
          QKilosSalida.FieldByName('cajas_sl').AsInteger:= cajas_1;
          QKilosSalida.FieldByName('n_palets_sl').AsInteger:= n_palets_1;
          QKilosSalida.FieldByName('kilos_sl').AsFloat:= kilos_1;
          QKilosSalida.FieldByName('importe_neto_sl').AsFloat:= importe_neto_1;
          QKilosSalida.FieldByName('iva_sl').AsFloat:= iva_1;
          QKilosSalida.FieldByName('importe_total_sl').AsFloat:= importe_total_1;
          QKilosSalida.FieldByName('emp_procedencia_sl').AsString:= ADestino;
          Post;
        end;

        with QKilosSalida do
        begin
          Insert;
          QKilosSalida.FieldByName('empresa_sl').AsString:= empresa_sl;
          QKilosSalida.FieldByName('centro_salida_sl').AsString:= centro_salida_sl;
          QKilosSalida.FieldByName('centro_origen_sl').AsString:= centro_origen_sl;
          QKilosSalida.FieldByName('producto_sl').AsString:= producto_sl;
          QKilosSalida.FieldByName('envase_sl').AsString:= envase_sl;
          QKilosSalida.FieldByName('marca_sl').AsString:= marca_sl;
          QKilosSalida.FieldByName('categoria_sl').AsString:= categoria_sl;
          QKilosSalida.FieldByName('calibre_sl').AsString:= calibre_sl;
          QKilosSalida.FieldByName('color_sl').AsString:= color_sl;
          QKilosSalida.FieldByName('unidad_precio_sl').AsString:= unidad_precio_sl;
          QKilosSalida.FieldByName('tipo_iva_sl').AsString:= tipo_iva_sl;
          QKilosSalida.FieldByName('federacion_sl').AsString:= federacion_sl;
          QKilosSalida.FieldByName('cliente_sl').AsString:= cliente_sl;
          QKilosSalida.FieldByName('n_albaran_sl').AsInteger:= n_albaran_sl;
//          if IntToStr(ref_transitos_sl) <> '' then
//            QKilosSalida.FieldByName('ref_transitos_sl').AsInteger:= ref_transitos_sl;
          QKilosSalida.FieldByName('fecha_sl').AsDateTime:= fecha_sl;
          QKilosSalida.FieldByName('precio_sl').AsFloat:= precio_sl;
          QKilosSalida.FieldByName('porc_iva_sl').AsFloat:= porc_iva_sl;

          QKilosSalida.FieldByName('cajas_sl').AsInteger:= cajas_2;
          QKilosSalida.FieldByName('n_palets_sl').AsInteger:= n_palets_2;
          QKilosSalida.FieldByName('kilos_sl').AsFloat:= kilos_2;
          QKilosSalida.FieldByName('importe_neto_sl').AsFloat:= importe_neto_2;
          QKilosSalida.FieldByName('iva_sl').AsFloat:= iva_2;
          QKilosSalida.FieldByName('importe_total_sl').AsFloat:= importe_total_2;
          QKilosSalida.FieldByName('emp_procedencia_sl').AsString:= emp_procedencia_sl;
          QKilosSalida.FieldByName('tipo_palets_sl').AsString := tipo_palets_sl;
          QKilosSalida.FieldByName('comercial_sl').AsString := comercial_sl;
          QKilosSalida.FieldByName('id_linea_albaran_sl').AsInteger := n_linea + 1;

          Post;
        end;
        QKilosSalida.Database.Commit;
        result:= rKilos;
      except
        QKilosSalida.Database.Rollback;
        ShowMessage('Error al separar lineas de salidas, por favor intentelo mas tarde.');
      end;
    end
    else
    begin
      ShowMessage('En este momento no se pueden separar lineas de salidas, por favor intentelo mas tarde.');
    end;
  end
  else
  begin
    ShowMessage('Kilos = 0.');
  end;
end;

end.

