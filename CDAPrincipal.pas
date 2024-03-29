unit CDAPrincipal;

interface

uses
  SysUtils, Classes, DB, DBTables;

type
  TDAPrincipal = class(TDataModule)
    DBPrincipal: TDatabase;
    QKilosAprovechados: TQuery;
    QKilosSalida: TQuery;
    QKilosTerceros: TQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure SQLKilosAprovecha( const ACentro, AProducto, ACosecheros: string );
//    function EsAgrupacionTomate( const AProducto: String):boolean;
  public
    { Public declarations }
    procedure KilosAprovecha( const AEmpresa, ACentro, AProducto, ACosecheros: String;
                          const AFechaini, AFechaFin: TDateTime;
                          var VPrimera, VSegunda, VTercera, VDestrio, VMerma: Real );
    procedure KilosSalida( const AEmpresa, ACentro, AProducto: String;
                          const AFechaini, AFechaFin: TDateTime;
                          var VPrimera, VSegunda, VTercera, VDestrio, VBotado: Real );
    procedure KilosTerceros( const AEmpresa, ACentro, AProducto: String;
                          const AFechaini, AFechaFin: TDateTime;
                          var VPrimera, VSegunda, VTercera, VDestrio, VBotado: Real );
    function EsAgrupacionTomate( const AProducto: String):boolean;

  end;

var
  DAPrincipal: TDAPrincipal;

implementation

{$R *.dfm}

procedure TDAPrincipal.DataModuleCreate(Sender: TObject);
begin
  with QKilosSalida do
  begin
    SQL.Clear;
    SQL.Add(' select categoria_sl, sum(kilos_sl) kilos ');
    SQL.Add(' from frf_salidas_l, frf_salidas_c ');
    SQL.Add(' where empresa_sl = :empresa ');
    SQL.Add(' and centro_salida_sl = :centro ');
    SQL.Add(' and fecha_sl between :fechaini and :fechafin ');
    SQL.Add(' and producto_sl = :producto ');
    SQL.Add(' and empresa_sc = empresa_sl ');
    SQL.Add(' and centro_salida_sc = centro_salida_sl ');
    SQL.Add(' and n_albaran_sc = n_albaran_sl  ');
    SQL.Add(' and fecha_sc = fecha_sl          ');
    SQL.Add(' and n_factura_sc is not null     ');
    SQL.Add(' and es_transito_sc <> 2 ');         //Tipo Salida: Devolucion
    SQL.Add(' group by 1 ');
    Prepare;
  end;
  with QKilosTerceros do
  begin
    SQL.Clear;
    SQL.Add(' select categoria_st, sum(kilos_st) kilos ');
    SQL.Add(' from frf_salidas_terceros, frf_salidas_c ');
    SQL.Add(' where empresa_st = :empresa ');
    SQL.Add(' and centro_salida_st = :centro ');
    SQL.Add(' and fecha_st between :fechaini and :fechafin ');
    SQL.Add(' and producto_st = :producto ');
    SQL.Add(' and emp_procedencia_st <> empresa_st');
    SQL.Add(' and empresa_sc = empresa_st ');
    SQL.Add(' and centro_salida_sc = centro_salida_st ');
    SQL.Add(' and n_albaran_sc = n_albaran_st  ');
    SQL.Add(' and fecha_sc = fecha_st          ');
    SQL.Add(' and n_factura_sc is not null     ');
    SQL.Add(' and es_transito_sc <> 2 ');         //Tipo Salida: Devolucion
    SQL.Add(' group by 1 ');
    Prepare;
  end;
end;

procedure TDAPrincipal.DataModuleDestroy(Sender: TObject);
  procedure Desprepara( var VQuery: TQuery );
  begin
    VQuery.Cancel;
    VQuery.Close;
    if VQuery.Prepared then
      VQuery.UnPrepare;
  end;
begin
  Desprepara( QKilosSalida );
  Desprepara( QKilosTerceros );
end;

function TDAPrincipal.EsAgrupacionTomate(const AProducto: String): boolean;
var QAux: TQuery;
begin
  QAux := TQuery.Create(Self);
  with QAUx do
  try
    DataBaseName := 'DBPrincipal';
    SQL.Clear;
    SQL.Add(' select * from frf_agrupacion ');
    SQL.Add('  where producto_a = :producto ');
    SQL.Add('    and codigo_a = 1 ');             // Agrupacion Tomate

    ParamByName('producto').AsString := AProducto;
    Open;

    result := not IsEmpty;

  finally
    free;
  end;

end;

procedure TDAPrincipal.SQLKilosAprovecha( const ACentro, AProducto, ACosecheros: string );
begin
  if ((EsAgrupacionTomate(AProducto)) and (ACentro = '1')) or
     ((AProducto = 'CAL') and (ACentro = '1')) then
  begin
    with QKilosAprovechados do
    begin
      SQL.Clear;
      SQL.Add(' select ');
      SQL.Add('        round( sum( ( porcen_primera_e * total_kgs_e2l ) / 100 ), 2 ) primera, ');
      SQL.Add('        round( sum( ( porcen_segunda_e * total_kgs_e2l ) / 100 ), 2 ) segunda, ');
      SQL.Add('        round( sum( ( porcen_tercera_e * total_kgs_e2l ) / 100 ), 2 ) tercera, ');
      SQL.Add('        round( sum( ( porcen_destrio_e * total_kgs_e2l ) / 100 ), 2 ) destrio, ');
      SQL.Add('        round( sum( ( aporcen_merma_e * total_kgs_e2l ) / 100 ), 2 ) merma ');

      SQL.Add(' from frf_entradas2_l, frf_escandallo ');
      SQL.Add(' where empresa_e2l = :empresa ');
      
      SQL.Add(' and centro_e2l in (:centro,6) ');   // :centro ');    Se buscan compras en centro 1 - los llanos y 6 - Tenerife. Luego se asignaran ventas del centro 1
      SQL.Add(' and fecha_e2l between :fechaini and :fechafin ');
      SQL.Add(' and producto_e2l = :producto ');

      if Trim(ACosecheros) <> '' then
        SQL.Add(' and cosechero_e2l in ( ' + ACosecheros + '  ) ');

      SQL.Add(' and empresa_e = empresa_e2l ');
      SQL.Add(' and centro_e = centro_e2l ');
      SQL.Add(' and numero_entrada_e = numero_entrada_e2l ');
      SQL.Add(' and fecha_e = fecha_e2l ');
      SQL.Add(' and producto_e = :producto ');
      SQL.Add(' and cosechero_e = cosechero_e2l ');

      Prepare;
    end;
  end
  else if ACentro = '3' then
  begin
    with QKilosAprovechados do
    begin
      SQL.Clear;
      SQL.Add(' select ');
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

      if Trim(ACosecheros) <> '' then
        SQL.Add(' and cosechero_e2l in ( ' + ACosecheros + '  ) ');

      Prepare;
    end;
  end
  else
  begin
    with QKilosAprovechados do
    begin
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

      if Trim(ACosecheros) <> '' then
        SQL.Add(' and cosechero_e2l in ( ' + ACosecheros + '  ) ');

      Prepare;
    end;
  end;
end;

procedure TDAPrincipal.KilosAprovecha( const AEmpresa, ACentro, AProducto, ACosecheros: String;
                         const AFechaini, AFechaFin: TDateTime;
                         var VPrimera, VSegunda, VTercera, VDestrio, VMerma: Real );
begin
  SQLKilosAprovecha( ACentro, AProducto, ACosecheros );
  with QKilosAprovechados do
  begin
    ParamByName('empresa').AsString:= AEmpresa;
    ParamByName('centro').AsString:= ACentro;
    ParamByName('producto').AsString:= AProducto;
    ParamByName('fechaini').AsDateTime:= AFechaini;
    ParamByName('fechafin').AsDateTime:= AFechaFin;
    Open;
    VPrimera:= FieldByName('primera').AsFloat;
    VSegunda:= FieldByName('segunda').AsFloat;
    VTercera:= FieldByName('tercera').AsFloat;
    VDestrio:= FieldByName('destrio').AsFloat;
    VMerma:= FieldByName('merma').AsFloat;
    Close;
  end;
end;

procedure TDAPrincipal.KilosSalida( const AEmpresa, ACentro, AProducto: String;
                         const AFechaini, AFechaFin: TDateTime;
                         var VPrimera, VSegunda, VTercera, VDestrio, VBotado: Real );
begin
  VPrimera:= 0;
  VSegunda:= 0;
  VTercera:= 0;
  VDestrio:= 0;
  VBotado:=  0;

  with QKilosSalida do
  begin
    ParamByName('empresa').AsString:= AEmpresa;
    ParamByName('centro').AsString:= ACentro;
    ParamByName('producto').AsString:= AProducto;
    ParamByName('fechaini').AsDateTime:= AFechaini;
    ParamByName('fechafin').AsDateTime:= AFechaFin;
    Open;
    while not Eof do
    begin
      if FieldByName('categoria_sl').AsString = '1' then
      begin
        VPrimera:= VPrimera + FieldByName('kilos').AsFloat;
      end
      else
      if FieldByName('categoria_sl').AsString = '2' then
      begin
        VSegunda:= VSegunda + FieldByName('kilos').AsFloat;
      end
      else
      if FieldByName('categoria_sl').AsString = '3' then
      begin
        VTercera:= VTercera + FieldByName('kilos').AsFloat;
      end
      else
      if FieldByName('categoria_sl').AsString = 'B' then
      begin
        VBotado:= VBotado + FieldByName('kilos').AsFloat;
      end
      else
      begin
        VDestrio:= VDestrio + FieldByName('kilos').AsFloat;
      end;
      Next;
    end;
    Close;
  end;
end;


procedure TDAPrincipal.KilosTerceros( const AEmpresa, ACentro, AProducto: String;
                         const AFechaini, AFechaFin: TDateTime;
                         var VPrimera, VSegunda, VTercera, VDestrio, VBotado: Real );
begin
  VPrimera:= 0;
  VSegunda:= 0;
  VTercera:= 0;
  VDestrio:= 0;
  VBotado:=  0;

  with QKilosTerceros do
  begin
    ParamByName('empresa').AsString:= AEmpresa;
    ParamByName('centro').AsString:= ACentro;
    ParamByName('producto').AsString:= AProducto;
    ParamByName('fechaini').AsDateTime:= AFechaini;
    ParamByName('fechafin').AsDateTime:= AFechaFin;
    Open;
    while not Eof do
    begin
      if FieldByName('categoria_st').AsString = '1' then
      begin
        VPrimera:= VPrimera + FieldByName('kilos').AsFloat;
      end
      else
      if FieldByName('categoria_st').AsString = '2' then
      begin
        VSegunda:= VSegunda + FieldByName('kilos').AsFloat;
      end
      else
      if FieldByName('categoria_st').AsString = '3' then
      begin
        VTercera:= VTercera + FieldByName('kilos').AsFloat;
      end
      else
      if FieldByName('categoria_st').AsString = 'B' then
      begin
        VBotado:= VBotado + FieldByName('kilos').AsFloat;
      end
      else
      begin
        VDestrio:= VDestrio + FieldByName('kilos').AsFloat;
      end;
      Next;
    end;
    Close;
  end;
end;

end.
