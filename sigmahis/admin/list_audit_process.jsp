<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String codigo = "";
String name = "", estado="";
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");
StringBuffer sbSql = new StringBuffer();
StringBuffer sbAppendFilter = new StringBuffer();
String schemaName ="";
String schemaTblPrexix ="";
String userName = request.getParameter("user_name");
String companyId = (String)session.getAttribute("_companyId");
String process = request.getParameter("process")==null?"":request.getParameter("process");
String subProcess = request.getParameter("sub_process")==null?"":request.getParameter("sub_process");
String processName = request.getParameter("processName")==null?"":request.getParameter("processName");
String fromDate = request.getParameter("from_date")==null?"":request.getParameter("from_date");
String toDate = request.getParameter("to_date")==null?"":request.getParameter("to_date");
String innerAppendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String idDoc = request.getParameter("idDoc")==null?"":request.getParameter("idDoc");
String noDoc = request.getParameter("noDoc")==null?"":request.getParameter("noDoc");

ArrayList<String> alTblTitle = new ArrayList<String>();

CommonDataObject cdoS = SQLMgr.getData("select nvl(get_sec_comp_param("+companyId+",'AUD_SCHEMA'),'-1') as schemaData from dual");

if (cdoS != null){
		String _schemaData = cdoS.getColValue("schemaData");
	try{
		schemaName = _schemaData.split("@@")[0];
		schemaTblPrexix = _schemaData.split("@@")[1];
	}catch(Exception e){e.printStackTrace();}
}

if (userName == null || "".equals(userName)) userName = (String)session.getAttribute("_userName");
if (fromDate.equals("")) fromDate = cDateTime.substring(0,10);
if (toDate.equals("")) toDate = cDateTime.substring(0,10);

Exception up = new Exception("No pudimos identificar el nombre del esquema!");
if (schemaName.trim().equals("")) throw up; //--> classic :D
else if (schemaName.equals("-1")) throw new Exception("El sistema no tiene habilitado Auditorías. Por favor consulte con su Administrador!");

if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=1000;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
	{
		appendFilter += " and upper(a.aud_action) = '"+request.getParameter("estado").toUpperCase()+"'";
		searchOn = "estado";
		searchVal = request.getParameter("estado");
		searchType = "1";
		searchDisp = "Estado";
		estado = request.getParameter("estado");
	}
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
	{
	 if (searchType.equals("1"))
	 {
		 appendFilter += " where upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
	 }
	}
	else
	{
		searchOn="SO";
		searchVal="Todos";
		searchType="ST";
		searchDisp="Listado";
	}

	// ORDEN DE COMPRA
if (process.trim().equals("ORDENCOM")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment

	 alTblTitle.add("1@@Año@@5@@center");
	 alTblTitle.add("3@@No.Sol@@7@@center");
	 alTblTitle.add("4@@F.Doc@@7@@center");
	 alTblTitle.add("5@@No.Fac@@10@@center");
	 alTblTitle.add("6@@Estado@@7@@center"); // -4
	 alTblTitle.add("7@@Proveedor@@25@@left");

	 //No.Fila
	 //alTblTitle.add("8@@NoFila@@4@@center");

	 //Monto
	 alTblTitle.add("8@@Monto&nbsp;@@7@@right");

	CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	if (cdoFilter != null){
		innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	//innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);
		innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc).replaceAll("@@num_doc",noDoc);

	sbAppendFilter.append(innerAppendFilter);
	}

 //AUDDEVELOPMENT.AUD$com_detalle_compromiso

	sbSql.append("select a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.anio as field1, a.tipo_compromiso as field2, a.num_doc as field3, to_char(a.fecha_documento,'dd/mm/yyyy')  as field4, a.numero_factura as field5,decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE','F','APROBADO FINA','C','APROBADO CONTA','Z','CERRADO') as field6, p.nombre_proveedor as field7 ");

	/*
	sbSql.append(",(select count(*) from ");

	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);

	sbSql.append("com_detalle_compromiso d where d.cf_anio = a.anio and d.compania = a.compania and d.cf_tipo_com = a.tipo_compromiso and d.cf_num_doc = a.num_doc and d.aud_timestamp = a.fecha_del_sistema and d.aud_action = 'INS') ");
	sbSql.append("||'-'||(select count(*) from ");
	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);

	sbSql.append(" tbl_com_detalle_compromiso d where d.cf_anio = a.anio and d.compania = a.compania and d.cf_tipo_com = a.tipo_compromiso and d.cf_num_doc = a.num_doc) ");

	sbSql.append(" as field9 ");*/

	sbSql.append(", a.monto_total as field8, '' as field10, '' as fieldGr from ");
	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);
	sbSql.append("com_comp_formales a, tbl_com_proveedor p");
	sbSql.append(" where ");
	sbSql.append(sbAppendFilter);
	sbSql.append(appendFilter);
	sbSql.append(" and a.aud_action in ('INS','UPD') and a.cod_proveedor = p.cod_provedor order by 1 desc");
}  else

// RECEPCION DE MATERIALES
 if (process.trim().equals("RECEP")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment

		 alTblTitle.add("1@@Año@@5@@center");
	 alTblTitle.add("2@@No.Recep.@@7@@center");
	 alTblTitle.add("3@@Almacen@@20@@left");
	 alTblTitle.add("4@@F.Doc@@7@@center");
	 alTblTitle.add("5@@No.Fac@@10@@center");
	 alTblTitle.add("6@@Estado@@11@@center");
	alTblTitle.add("7@@Proveedor@@30@@left");

	CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	if (cdoFilter != null){
		innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	//innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);
	innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc).replaceAll("@@num_doc",noDoc);
		sbAppendFilter.append(innerAppendFilter);
	}

	sbSql.append("select  a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc,  a.anio_recepcion as field1, a.numero_documento as field2,  c.descripcion as field3, to_char(a.fecha_documento,'dd/mm/yyyy') as field4, a.numero_factura as field5, decode(a.estado,'A','ANULADO','R','RECIBIDO') as field6, b.nombre_proveedor as field7, '' as field8, '' as field9, '' as field10,  decode(a.fre_documento,'OC','CON ORDEN DE COMPRA','NE','CON NOTA DE ENTREGA','FG','A CONSIGNACION', 'FR','SIN ORDEN DE COMPRA','FC','SIN ORDEN DE COMPRA') as fieldGr from ");
	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);
	sbSql.append("inv_recepcion_material a, tbl_com_proveedor b, tbl_inv_almacen c");
	sbSql.append(" where ");
	sbSql.append(sbAppendFilter);
	sbSql.append(appendFilter);
	sbSql.append(" and a.aud_action in ('INS','UPD') and a.compania = b.compania and a.cod_proveedor = b.cod_provedor and a.compania = c.compania and a.codigo_almacen = c.codigo_almacen and a.tipo_factura ='I' order by 1 desc,2 ");
}else

 // ORDEN DE PAGO
 if (process.trim().equals("ORDPAG")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment

		 alTblTitle.add("1@@Año@@5@@center");
	 alTblTitle.add("2@@No.Orden.@@7@@center");
	 alTblTitle.add("3@@Beneficiario@@20@@left");
	 alTblTitle.add("4@@F.OrdenPago@@7@@center");
	 alTblTitle.add("5@@Ck.Impreso@@10@@center");
	 alTblTitle.add("6@@Estado@@11@@center");
	alTblTitle.add("8@@Monto@@30@@right");

	CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	if (cdoFilter != null){
		innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	//innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);
	innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc).replaceAll("@@num_doc",noDoc);
		sbAppendFilter.append(innerAppendFilter);
	}

	sbSql.append("select  a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc,  a.anio as field1, a.num_orden_pago as field2,  a.nom_beneficiario as field3, to_char(a.fecha_solicitud,'dd/mm/yyyy') as field4, a.cheque_impreso as field5, decode(a.estado,'P','PENDIENTE','A', 'APROBADO','R','RECHAZADO','N','ANULADO',a.estado) as field6, a.tipo_orden as field7, to_char(a.monto,'99,999,999,990.00') as field8, '' as field9, '' as field10,  b.descripcion as fieldGr from ");
	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);
	sbSql.append("cxp_orden_de_pago a, tbl_cxp_tipo_orden_pago b");
	sbSql.append(" where ");
	sbSql.append(sbAppendFilter);
	sbSql.append(appendFilter);
	sbSql.append(" and a.aud_action in ('INS','UPD') and a.cod_tipo_orden_pago = b.cod_tipo_orden_pago order by 1 desc ");
}else

	// CHEQUES GENERADOS
 if (process.trim().equals("GENCK")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment

	 alTblTitle.add("1@@Año@@5@@center");
	 alTblTitle.add("2@@No.Orden.@@7@@center");
	 alTblTitle.add("3@@Beneficiario@@15@@left");
	 alTblTitle.add("4@@F.Cheque@@10@@center");
	 alTblTitle.add("5@@Num.Cheque@@8@@center");
	 alTblTitle.add("6@@Estado@@8@@center");
	 alTblTitle.add("8@@Tipo@@13@@center");
	 alTblTitle.add("7@@Monto@@22@@right");

	 CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	if (cdoFilter != null){
		innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	//innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);
	innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc).replaceAll("@@num_doc","'"+noDoc+"'");
		sbAppendFilter.append(innerAppendFilter);
	}

	sbSql.append("select  a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.anio as field1, a.num_orden_pago as field2, a.beneficiario  as field3, to_char(a.f_emision,'dd/mm/yyyy')  as field4, a.num_cheque as field5, decode(a.estado_cheque,'G','GIRADO','P','PAGADO','A','ANULADO') as field6, to_char(a.monto_girado,'999,999,999.00')  as field7,  b.descripcion as field8,'' as field9, '' as field10,   c.nombre||'   ...  '||' Cuenta Bancaria: '||a.cuenta_banco as fieldGr from ");
	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);
	sbSql.append("con_cheque a, tbl_cxp_tipo_orden_pago b, tbl_con_banco c");
	sbSql.append(" where ");
	sbSql.append(sbAppendFilter);
	sbSql.append(appendFilter);
	sbSql.append(" and a.aud_action in ('INS','UPD') and a.tipo_pago = b.cod_tipo_orden_pago and a.cod_compania = c.compania and a.cod_banco = c.cod_banco order by 1 desc ");
}else

//REQUISICION
if (process.trim().equals("REQ")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment

	 alTblTitle.add("1@@Año@@5@@center");
	 alTblTitle.add("2@@No.Sol@@7@@center");
	 alTblTitle.add("3@@T.Sol@@10@@center");
	 alTblTitle.add("4@@F.Doc@@7@@center");
	 alTblTitle.add("5@@T.Transf.@@10@@center");
	 alTblTitle.add("6@@Estado@@7@@center");
	 alTblTitle.add("7@@U.ADM/Almacén Receptor@@24@@left");

	CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	if (cdoFilter != null){
		innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	//innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);
	innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc).replaceAll("@@num_doc",noDoc);
		sbAppendFilter.append(innerAppendFilter);
	}

	java.util.Hashtable iXtra = new java.util.Hashtable();
	iXtra.put("ENTRE_ALMACEN","ENTRE ALMACENES");
	iXtra.put("REQ_PAC","ENTREGAS A PACIENTE");

	sbSql.append("select a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.anio as field1, a.solicitud_no as field2,  decode(a.tipo_solicitud,'D','DIARIO','S','SEMANAL','Q','QUINCENAL','M','MENSUAL') as field3, to_char(a.fecha_documento,'dd/mm/yyyy')  as field4, decode(a.tipo_transferencia,'U','UNIDAD ADM','A','ALMACEN','C','COMPAÑÍA') as field5, decode(a.estado_solicitud,'A', 'APROBADO', 'P', 'PENDIENTE', 'N','ANULADO','R','RECHAZADO?(ANTES PROCESADO?)','T','TRAMITE', 'E','ENTREGADO') as field6, decode(a.tipo_transferencia,'A', (select al.descripcion from tbl_inv_almacen al where al.compania = a.compania and al.codigo_almacen = a.codigo_almacen_ent and rownum = 1) , 'U', (select u.descripcion from tbl_sec_unidad_ejec u where u.compania = a.compania and a.unidad_administrativa = u.codigo and rownum = 1)  ) as field7 , '' as field8, '' as field9, '' as field10, 'ENTRE ALMACENES' fieldGr ");

	sbSql.append(" from ");
	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);
	sbSql.append("inv_solicitud_req a");
	sbSql.append(" where ");
	sbSql.append(sbAppendFilter);
	sbSql.append(appendFilter);
	sbSql.append(" and a.aud_action in ('INS','UPD') ");

	if (!subProcess.equals("")){
		sbSql.append(" and '");
		sbSql.append(iXtra.get(subProcess));
		sbSql.append("' = '");
		sbSql.append(iXtra.get(subProcess));
		sbSql.append("'");
	}

	sbSql.append(" union all select a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.anio as field1, a.solicitud_no as field2,  'PAC' as field3, to_char(a.fecha_documento,'dd/mm/yyyy')  as field4, 'PACIENTE' as field5, decode(a.estado,'A', 'APROBADO', 'P', 'PENDIENTE', 'N','ANULADO','R','RECHAZADO?(ANTES PROCESADO?)','T','TRAMITE', 'E','ENTREGADO') as field6, (select al.descripcion from tbl_inv_almacen al where al.compania = a.compania and al.codigo_almacen = a.codigo_almacen and rownum = 1) as field7 , '' as field8, '' as field9, '' as field10, 'ENTREGAS A PACIENTE' fieldGr  ");

	sbSql.append(" from ");
	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);
	sbSql.append("inv_solicitud_pac a");
	sbSql.append(" where ");
	sbSql.append(sbAppendFilter);
	sbSql.append(appendFilter);
	sbSql.append(" and a.aud_action in ('INS','UPD') ");

	if (!subProcess.equals("")){
		sbSql.append(" and '");
		sbSql.append(iXtra.get(subProcess));
		sbSql.append("' = '");
		sbSql.append(iXtra.get(subProcess));
		sbSql.append("'");
	}


	sbSql.append(" order by 16, 1 ");

} else
	// FACTURACION
 if (process.trim().equals("FACT")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment

	 alTblTitle.add("1@@Num.Factura@@10@@center");
	 alTblTitle.add("2@@Cod.Admin@@10@@center");
	 alTblTitle.add("3@@Cliente@@20@@left");
	 alTblTitle.add("4@@Fecha@@10@@center");
	 alTblTitle.add("5@@Empresa@@8@@left");
	 alTblTitle.add("6@@Estado@@8@@center");
	 alTblTitle.add("7@@Impreso@@13@@center");
	 alTblTitle.add("8@@Monto@@22@@right");


	CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	if (cdoFilter != null){
		innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	//innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);
		innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc).replaceAll("@@num_doc","'"+noDoc+"'");

		sbAppendFilter.append(innerAppendFilter);
	}

	sbSql.append("select  a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.codigo as field1, get_f_nac(a.pac_id)||decode(a.admi_codigo_paciente,null,'',' ('||a.admi_codigo_paciente)||decode(a.admi_secuencia,null,'',') ('||a.admi_secuencia||')')  as field2, getNombreCliente(a.compania,a.cliente_otros,a.cod_otro_cliente) as field3,to_char(a.fecha,'dd/mm/yyyy') as field4,    nvl((select d.nombre from tbl_adm_empresa d where d.codigo = a.cod_empresa),'Sin Empresa') as field5, decode(a.estatus,'A','ANULADA','P','PENDIENTE','C','CANCELADA') as field6,  decode(nvl((select count(*) from tbl_fac_dgi_documents where tipo_docto in ('FACP','FACT') and impreso = 'Y' and codigo = a.codigo),0),'0','N','S') as field7, to_char(a.grang_total,'999,999,999,990.00') as field8,  '' as field9, '' as field10 , nvl((select descripcion from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania),'Sin Definir') as fieldGr from ");
	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);
	sbSql.append("fac_factura a");
	sbSql.append(" where ");
	sbSql.append(sbAppendFilter);
	sbSql.append(appendFilter);
	sbSql.append(" and a.aud_action in ('INS','UPD') order by 1 desc ");
} else


	// RECIBOS
 if (process.trim().equals("REC")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment

	 alTblTitle.add("1@@Codigo@@5@@center");
	 alTblTitle.add("2@@Num.Recibo@@8@@center");
	 alTblTitle.add("3@@Cliente@@20@@left");
	 alTblTitle.add("4@@Fecha@@10@@center");
	 alTblTitle.add("5@@Caja@@5@@center");
	 alTblTitle.add("6@@Impreso@@6@@center");
	 alTblTitle.add("7@@Estado@@10@@center");
	 alTblTitle.add("8@@Monto@@12@@right");
	 alTblTitle.add("9@@Aplicado@@5@@center");
	 alTblTitle.add("10@@Ajustado@@5@@center");

	CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	if (cdoFilter != null){
		innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	//innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);

	innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc).replaceAll("@@num_doc","'"+noDoc+"'");
		sbAppendFilter.append(innerAppendFilter);
	}

	sbSql.append("select  a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.anio||'-'||a.codigo as field1,  a.recibo as field2, a.nombre as field3, to_char(a.fecha,'dd/mm/yyyy') as field4, a.caja as field5,  a.rec_impreso as field6,  decode(a.rec_status,'A','ACTIVO','I','ANULADO',a.rec_status) as field7, to_char(a.pago_total,'999,999,999,990.00') as field8, decode( (select nvl(sum(monto),0) from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.anio and codigo_transaccion = a.codigo),0,'N','S') as field9, decode((select nvl(sum(case when z.tipo_ajuste not in (select column_value  from table( select split((select get_sec_comp_param(z.compania,'CJA_TP_AJ_REC') from dual),',') from dual  )) then decode(z.lado_mov,'D',-z.monto,'C',z.monto) else 0 end ),0) as ajuste from vw_con_adjustment_gral z, tbl_fac_tipo_ajuste y where z.recibo = a.recibo and z.compania = a.compania and z.factura is null and z.tipo_doc = 'R' and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in ('H','D')),0,'N','S') as field10 , decode(a.tipo_cliente,'P','PACIENTE','E','EMPRESA','O','OTROS') as fieldGr from ");
	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);
	sbSql.append("cja_transaccion_pago a");
	sbSql.append(" where ");
	sbSql.append(sbAppendFilter);
	sbSql.append(appendFilter);
	sbSql.append(" and a.aud_action in ('INS','UPD') order by 1 desc ");
} else


	// AJUSTES CXP
 if (process.trim().equals("AJCXP")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment

	 alTblTitle.add("1@@Año@@5@@center");
	 alTblTitle.add("2@@Codigo@@8@@center");
	 alTblTitle.add("3@@Cliente@@20@@left");
	 alTblTitle.add("4@@Fecha@@10@@center");
	 alTblTitle.add("5@@Num.Factura@@5@@center");
	 alTblTitle.add("6@@Estado@@6@@center");
	 alTblTitle.add("7@@Ref.Id@@10@@center");
	 alTblTitle.add("8@@Monto@@15@@right");


	CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	if (cdoFilter != null){
		innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	//innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);
	innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc).replaceAll("@@num_doc",noDoc);
		sbAppendFilter.append(innerAppendFilter);
	}

	sbSql.append("select  a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.anio as field1, a.id as field2, nvl(decode(a.destino_ajuste,'H',(select m.primer_nombre || decode(m.segundo_nombre, null, '', ' ' || m.segundo_nombre) || ' ' || m.primer_apellido || decode(m.segundo_apellido, null, '', ' ' || m.segundo_apellido) || decode(m.sexo, 'F', decode(m.apellido_de_casada, null, '', ' ' || m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = to_char(a.ref_id)),'E',(select nombre from tbl_adm_empresa where codigo =a.ref_id),(select c.nombre_proveedor from tbl_com_proveedor c where c.compania=a.compania and c.cod_provedor=to_number(a.ref_id))),'S/NOMBRE') as field3, to_char(a.fecha,'dd/mm/yyyy') as field4, a.numero_factura as field5,  decode(a.estado,'P','PENDIENTE','R','APROBADO','A','ANULADO') as field6, decode(a.destino_ajuste,'H',(select nvl(reg_medico,codigo) from tbl_adm_medico m where m.codigo = to_char(a.ref_id) ),a.ref_id) as field7, TO_CHAR(a.monto,'999,999,999,990.00') as field8, '' as field9, '' as field10 ,   (select b.descripcion from tbl_cxp_tipo_ajuste b where a.cod_tipo_ajuste = b.cod_tipo_ajuste ) as fieldGr  from ");
	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);
	sbSql.append("cxp_ajuste_saldo_enc a");
	sbSql.append(" where ");
	sbSql.append(sbAppendFilter);
	sbSql.append(appendFilter);
	sbSql.append(" and a.aud_action in ('INS','UPD') order by 1 desc");
}
else
if (process.trim().equals("PAC")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment

	 alTblTitle.add("1@@Primer Nombre@@10@@left");
	 alTblTitle.add("2@@Segundo Nombre@@10@@left");
	 alTblTitle.add("3@@Cédula@@10@@left");
	 alTblTitle.add("4@@F.Nac@@7@@center");
	 alTblTitle.add("5@@Sexo@@5@@center");
	 alTblTitle.add("6@@ID@@7@@center");
	 alTblTitle.add("7@@Dirección Residencial@@21@@left");

	 CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	 if (cdoFilter != null){
		 innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	 //innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);
	 innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc).replaceAll("@@num_doc",noDoc);
		 sbAppendFilter.append(innerAppendFilter);
	 }

		sbSql.append("select  a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.primer_nombre as field1, a.primer_apellido as field2,decode (tipo_id_paciente,'P',pasaporte,provincia|| '-'|| sigla|| '-'|| tomo|| '-'|| asiento|| '-'|| d_cedula) as field3,to_char(nvl(f_nac,fecha_nacimiento),'dd/mm/yyyy') as field4, a.sexo as field5, a.residencia_direccion as field7, a.pac_id as field6 from ");
		sbSql.append(schemaName);
		sbSql.append(".");
		sbSql.append(schemaTblPrexix);
		sbSql.append("ADM_PACIENTE a");
		sbSql.append(" where ");
		sbSql.append(sbAppendFilter);
		sbSql.append(appendFilter);
		sbSql.append(" and a.aud_action in ('INS','UPD') order by 1 desc");

}
else
if (process.trim().equals("ART")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment
	 alTblTitle.clear();

	 alTblTitle.add("1@@Cód.Art@@7@@center");
	 alTblTitle.add("2@@Descripción@@21@@left");
	 alTblTitle.add("3@@ITBM@@4@@center");
	 alTblTitle.add("4@@CONS@@4@@center");
	 alTblTitle.add("5@@CONTAB@@4@@center");
	 alTblTitle.add("6@@Precio@@4@@right");
	 alTblTitle.add("7@@Estado@@5@@center");
	 alTblTitle.add("8@@Cód.Barra@@10@@center");
	 alTblTitle.add("9@@Tech.Desc@@15@@left");

	 CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	 if (cdoFilter != null){
		 innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	 //innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);
	innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc);

		 sbAppendFilter.append(innerAppendFilter);
	 }

		sbSql.append("select  a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.cod_articulo field1, a.descripcion as field2, a.itbm as field3, a.consignacion_sino as field4, other4 field5,a.precio_venta as field6, a.estado as field7, a.cod_barra as field8,a.tech_descripcion as field9, (select nombre from tbl_inv_familia_articulo where cod_flia = a.cod_flia and compania = a.compania )||' - '||a.cod_flia fieldGr1, (select descripcion from tbl_inv_clase_articulo where compania = a.compania and cod_flia = a.cod_flia and cod_clase = a.cod_clase )||' - '||a.cod_clase as fieldGr2,other4 as conta from ");
		sbSql.append(schemaName);
		sbSql.append(".");
		sbSql.append(schemaTblPrexix);
		sbSql.append("INV_ARTICULO a");
		sbSql.append(" where ");
		sbSql.append(sbAppendFilter);
		sbSql.append(appendFilter);
		sbSql.append(" and a.aud_action in ('INS','UPD') order by 1 desc");

}
else if (process.trim().equals("USOS")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment
	 alTblTitle.clear();

	 alTblTitle.add("1@@Cód.Uso@@7@@center");
	 alTblTitle.add("2@@Descripción@@28@@left");
	 alTblTitle.add("3@@T.SERV@@25@@left");
	 alTblTitle.add("4@@Precio@@5@@right");
	 alTblTitle.add("5@@Estado@@5@@center");

	 CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	 if (cdoFilter != null){
		 innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	 //innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);
	innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc);

		 sbAppendFilter.append(innerAppendFilter);
	 }

		sbSql.append("select  a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.codigo field1, a.descripcion as field2, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio and compania=a.compania ) as field3, precio_venta as field4, decode(a.estatus,'A','ACTIVO','I','INACTIVO',a.estatus) as field5  from ");
		sbSql.append(schemaName);
		sbSql.append(".");
		sbSql.append(schemaTblPrexix);
		sbSql.append("SAL_USO a");
		sbSql.append(" where ");
		sbSql.append(sbAppendFilter);
		sbSql.append(appendFilter);
		sbSql.append(" and a.aud_action in ('INS','UPD') order by 1 desc");

}

else
if (process.trim().equals("ADMIN")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment
	 alTblTitle.clear();

	 alTblTitle.add("1@@PacId@@7@@center");
	 alTblTitle.add("2@@Secuencia@@7@@center");
	 alTblTitle.add("3@@Nombre Paciente@@30@@left");
	 alTblTitle.add("4@@F.Ingreso@@7@@center");
	 alTblTitle.add("5@@F.Egreso@@7@@center");
	 alTblTitle.add("6@@Estado@@5@@center");


	 CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	 if (cdoFilter != null){
		 innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	 innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@pac_id",idDoc).replaceAll("@@secuencia",noDoc);
		 sbAppendFilter.append(innerAppendFilter);
	 }

		sbSql.append("select  a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.pac_id as field1, a.secuencia as field2, (select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id) as field3, to_char(a.fecha_ingreso,'dd/mm/yyyy') as field4, to_char(a.fecha_egreso,'dd/mm/yyyy') as field5, decode(a.estado,'A','ACTIVO','P','PRE-ADMISIONES','E','ESPERA','S','ESPECIAL','I','INACTIVO','N','ANULADA') as field6 ,a.aud_timestamp as timestamp from ");

		sbSql.append(schemaName);
		sbSql.append(".");
		sbSql.append(schemaTblPrexix);
		sbSql.append("adm_admision a");
		sbSql.append(" where ");
		sbSql.append(sbAppendFilter);
		sbSql.append(appendFilter);
		sbSql.append(" order by 11 desc");

}

else
if (process.trim().equals("CITAS")){

	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment
	 alTblTitle.clear();

	 alTblTitle.add("1@@#Cita@@5@@center");
	 alTblTitle.add("2@@F.Cita@@13@@center");
	 alTblTitle.add("3@@Habitación@@8@@Center");
	 alTblTitle.add("4@@Paciente@@18@@left");
	 alTblTitle.add("5@@Médico@@16@@left");
	 alTblTitle.add("6@@Estado@@10@@center");

	 CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	if (cdoFilter != null){
		innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	//innerAppendFilter = innerAppendFilter.replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId).replaceAll("@@cod_cita",codCita);
	innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@codigo",idDoc).replaceAll("@@fecha","to_date('"+toDate+"','dd/mm/yyyy')");

		sbAppendFilter.append(innerAppendFilter);
	}

		sbSql.append("select  a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.codigo as field1, to_char(a.hora_cita,'dd/mm/yyyy hh12:mi am') as field2, (select descripcion from tbl_sal_habitacion where codigo = a.habitacion and rownum = 1) as field3, case when a.admision is not null then (select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)||' **'||a.pac_id||'-'||a.admision else a.nombre_paciente end as field4, case when a.admision is not null then (select primer_nombre||' '||primer_apellido from  tbl_adm_medico where codigo = a.cod_medico) else a.nombre_medico end as field5, decode(a.estado_cita,'R','RESERVADA','C','CANCELADA','E','REALIZADA','T','TRANSFERIDA','X','CITA EN CONFLICTO') as field6, a.centro_servicio,(select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio and rownum = 1) fieldGr, a.cod_tipo, (select descripcion from tbl_cdc_tipo_cita where codigo = a.cod_tipo and rownum = 1) as fieldGr1 from ");

		sbSql.append(schemaName);
		sbSql.append(".");
		sbSql.append(schemaTblPrexix);
		sbSql.append("CDC_CITA a");
		sbSql.append(" where ");
		sbSql.append(sbAppendFilter);
		sbSql.append(appendFilter);
		sbSql.append(" order by 1 desc");

}else if (process.trim().equals("DEPOS")){
//Para Depositos de Efectivos y Cheques
	 //AUD User: 10%, AUD Fecha: 13%, AUD Acción: 7%	(30%)
	 //0:Field Number, 1:Title, 2:width, 3:alignment

	 alTblTitle.add("1@@Banco-Cuenta-Tipo-Consecutivo@@8@@center");
	 alTblTitle.add("2@@DocNum@@5@@center");
	 alTblTitle.add("3@@Fecha@@10@@left");
	 alTblTitle.add("4@@Observ@@10@@center");
	 alTblTitle.add("5@@Comment@@5@@center");
	 alTblTitle.add("6@@Monto@@6@@center");
	 alTblTitle.add("7@@Turnos@@10@@center");
	 alTblTitle.add("8@@MontoEffec@@10@@right");
	 alTblTitle.add("9@@MontoCheq@@10@@right");
	 alTblTitle.add("10@@TipoDoc@@10@@right");

  String idDocFilter ="";
	CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	if (cdoFilter != null){
		innerAppendFilter =  cdoFilter.getColValue("appendFilter");
	//innerAppendFilter = innerAppendFilter.replaceAll("@@user","'"+userName+":%'").replaceAll("@@user","'"+userName+"'").replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')").replaceAll("@@compania",companyId);
	if(idDoc == null || idDoc.trim().equals(""))idDocFilter=" is not null";
	else idDocFilter = "="+idDoc;
	innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@codigo",idDocFilter).replaceAll("@@from_date","to_date('"+fromDate+"','dd/mm/yyyy')").replaceAll("@@to_date","to_date('"+toDate+"','dd/mm/yyyy')");
		sbAppendFilter.append(innerAppendFilter);
	}

	sbSql.append("select a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, b.tipo_doc field10, a.compania, a.banco||'-'||a.cuenta_banco||'-'||a.tipo_movimiento||'-'||a.consecutivo_ag as field1,to_char(a.f_movimiento, 'dd/mm/yyyy') field3, a.num_documento as field2, a.observacion field4, a.descripcion  field5, a.monto field6, b.tipo_doc_desc, b.estado ,  decode(a.turno,'',a.turnos_cierre,a.turno) as field7,a.monto_efectivo field8,a.monto_cheque field9,a.banco||'-'||a.cuenta_banco||'-'||a.consecutivo_ag as fieldGr from ");
	sbSql.append(schemaName);
	sbSql.append(".");
	sbSql.append(schemaTblPrexix);
	sbSql.append("con_movim_bancario a,vw_con_mov_banco b");
	sbSql.append(" where ");
	sbSql.append(sbAppendFilter);
	sbSql.append(appendFilter);
	sbSql.append(" and a.compania=b.compania and b.cod_banco=a.banco and a.cuenta_banco=b.cuenta_banco and b.pref_doc=a.consecutivo_ag and a.tipo_movimiento=b.tipo_movimiento  and a.aud_action in ('INS','UPD') order by b.fecha_documento,a.consecutivo_ag,b.tipo_doc,a.aud_timestamp ");
}
else if (process.trim().equals("TURNOS")){

	 alTblTitle.clear();

	 alTblTitle.add("1@@Cód.@@7@@center");
	 alTblTitle.add("2@@Caja@@28@@left");
	 alTblTitle.add("3@@Cajero@@25@@left"); 
	 alTblTitle.add("4@@Estado@@5@@center");

	 CommonDataObject cdoFilter = SQLMgr.getData("select other1 as appendFilter from tbl_sec_audit_process where codigo = '"+process+"'");
	 if (cdoFilter != null){
		 innerAppendFilter =  cdoFilter.getColValue("appendFilter");
		 innerAppendFilter = innerAppendFilter.replaceAll("@@compania",companyId).replaceAll("@@anio",idDoc);

		 sbAppendFilter.append(innerAppendFilter);
	 }

		sbSql.append("select a.aud_timestamp as f_aud, a.aud_webuser_ip, to_char(a.aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_timestamp, a.aud_action, decode(a.aud_action,'INS','CREADO','UPD','MODIFICADO') as aud_action_desc, a.cod_turno field1,(select c.descripcion from tbl_cja_cajas c where c.compania = a.compania and c.codigo = a.cod_caja) as field2,nvl((select x.nombre from tbl_cja_cajera x,tbl_cja_turnos b where x.cod_cajera = b.cja_cajera_cod_cajera and x.compania = b.compania and b.compania =a.compania and b.codigo=a.cod_turno),' ')  as field3, decode(a.estatus,'A','ACTIVO','I','CERRADO','T','TRANSICION',a.estatus) as field4,' ' as field5  from ");
		sbSql.append(schemaName);
		sbSql.append(".");
		sbSql.append(schemaTblPrexix);
		sbSql.append("CJA_TURNOS_X_CAJAS a");
		sbSql.append(" where ");
		sbSql.append(sbAppendFilter);
		sbSql.append(appendFilter);
		sbSql.append(" and a.aud_action in ('INS','UPD') order by 1 desc");

}
if (request.getParameter("beginSearch")!=null && !sbSql.toString().equals("")){
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
}

if (searchDisp!=null) searchDisp=searchDisp;
else searchDisp = "Listado";

if (!searchVal.equals("")) searchValDisp=searchVal;
else searchValDisp="Todos";

int nVal, pVal;
int preVal=Integer.parseInt(previousVal);
int nxtVal=Integer.parseInt(nextVal);

if (nxtVal<=rowCount) nVal=nxtVal;
else nVal=rowCount;

if(rowCount==0) pVal=0;
else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_nocaps.jsp"%>
<script language="javascript">
document.title = 'Administración - Auditoria - '+document.title;
var sbAppendFilter = "<%=sbAppendFilter%>";
var appendFilter = "<%=appendFilter%>";
var sbSql = "<%=sbSql%>";

$(document).ready(function(){
	$("#process").change(function(){
		var process = $(this).val();
		if (process) {
		window.document.location = "../admin/list_audit_process.jsp?process="+process
	}
	else window.document.location = "../admin/list_audit_process.jsp";
	});

	$("#user_name").click(function(){
		$(this).select();
	});

	$("#go").click(function(){
		var process = "<%=process%>";
		var userName = $("#user_name").val();
		var codCita = $("#idDoc").val();
		var fromDate = $("#from_date").val();
		var toDate = $("#to_date").val();
	var __doSearch = false;

	if (process == "CITAS"){
		if (!codCita) {
		 alert("Por favor indique el ID de la CITA!");
		 __doSearch = false;
		}
		else __doSearch = true;
	}
	else{
		 if (userName) __doSearch = true;
		 else alert("Por favor ingrese el nombre de usuario!");
	}
	if(__doSearch) $("#search01").submit();
	});

	$("#btnCita").click(function(){
		abrir_ventana("../common/sel_cita.jsp?fp=AUD_CITA");
	});



});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - AUDITORIA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="4" align="right">&nbsp;

		</td>
	</tr>
	<tr>
		<td colspan="4" align="right">
			<!--<authtype type='3'><a href="javascript:manageConsentimiento()" class="Link00">[ <cellbytelabel id="1">Registrar Nuevo Consentimiento</cellbytelabel> ]</a></authtype>-->
		</td>
	</tr>

	<tr class="TextFilter">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("beginSearch","")%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="2">&nbsp;<cellbytelabel id="2">Proceso</cellbytelabel>&nbsp;
			<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_sec_audit_process order by 2","process",process, false, false,0,null,"width:200px","","Proceso","S")%>

						<%if(process.trim().equalsIgnoreCase("REQ")){%>
							<%=fb.select("sub_process","ENTRE_ALMACEN=Entre Almacenes,REQ_PAC=A Paciente",subProcess,"T")%>
						<%}%>

			<%if(!process.trim().equals("")){%>
			 &nbsp;<cellbytelabel id="3">Estado</cellbytelabel>&nbsp;
				<%=fb.select("estado","INS=Creado,UPD=Modificado",estado,"T")%>


<%if(process.trim().equals("ADMIN")||process.trim().equals("CITAS")||process.trim().equals("ART")||process.trim().equals("PAC")||process.trim().equals("USOS")||process.trim().equals("TURNOS")){%>
&nbsp;&nbsp;ID.:
<%}%>
<%if(process.trim().equals("DEPOS")){%>
&nbsp;&nbsp;CONSECUTIVO.:
<%}%>

				<%if(process.trim().equals("ORDENCOM")||process.trim().equals("AJCXP")||process.trim().equals("RECEP")||process.trim().equals("REQ")  ||process.trim().equals("FACT")||process.trim().equals("REC")||process.trim().equals("ORDPAG")||process.trim().equals("GENCK")){%>
					 &nbsp;&nbsp;AÑO:
				<%}
				if(process.trim().equals("ADMIN")||process.trim().equals("ORDENCOM")||process.trim().equals("AJCXP") ||process.trim().equals("RECEP")||process.trim().equals("REQ")  ||process.trim().equals("FACT")||process.trim().equals("REC")||process.trim().equals("ORDPAG")||process.trim().equals("GENCK")||process.trim().equals("ART")||process.trim().equals("CITAS")||process.trim().equals("PAC")||process.trim().equals("USOS")||process.trim().equals("DEPOS")||process.trim().equals("TURNOS")){%>
				<%=fb.textBox("idDoc",idDoc,(process.trim().equals("DEPOS"))?false:true,false,false,10,null,null,null)%>
				<%if(!process.trim().equals("ART")&&!process.trim().equals("CITAS")&&!process.trim().equals("PAC")&&!process.trim().equals("USOS")&&!process.trim().equals("DEPOS")&&!process.trim().equals("TURNOS")){%>
				&nbsp;&nbsp;NO. DOC:
				<%=fb.textBox("noDoc",noDoc,true,false,false,5,null,null,null)%>
				<%}%>
				<%}

				 if(process.trim().equals("CITAS")){%>Fecha:
						<%=fb.button("btnCita","...",true,false,null,null,"")%>
					<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="to_date"/>
				<jsp:param name="valueOfTBox1" value="<%=toDate%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>

				<%}
				if(process.trim().equals("DEPOS")){%>
				From:<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="from_date"/>
				<jsp:param name="valueOfTBox1" value="<%=fromDate%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>
				To:
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="to_date"/>
				<jsp:param name="valueOfTBox1" value="<%=toDate%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>

				<%}%>
				<%=fb.button("go","Ir",true,false,null,null,"")%>
				<%if(process.trim().equals("ART")){%>
						<%=fb.button("btn_costo","Ver variacion de costo",true,false,null,null,"onClick=\"javascript:abrir_ventana('../admin/list_audit_process_inv.jsp?idDoc="+idDoc+"&process="+process+"');\"")%>
						<%}%>
			<%}%>
			</td>
		<%=fb.formEnd(true)%>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
			<!--<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="4">Imprimir Lista</cellbytelabel> ]</a></authtype>-->
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("process",process)%>
				<%=fb.hidden("from_date",fromDate)%>
				<%=fb.hidden("to_date",toDate)%>
				<%=fb.hidden("user_name",userName)%>
				<%=fb.hidden("idDoc",idDoc)%>
				<%=fb.hidden("noDoc",noDoc)%>
				<%=fb.hidden("beginSearch","")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel>&nbsp;<%=rowCount%>&nbsp;</td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>&nbsp;<%=pVal%>&nbsp;<cellbytelabel id="7">hasta</cellbytelabel>&nbsp;<%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("process",process)%>
					<%=fb.hidden("from_date",fromDate)%>
						<%=fb.hidden("to_date",toDate)%>
					<%=fb.hidden("user_name",userName)%>
					<%=fb.hidden("idDoc",idDoc)%>
					<%=fb.hidden("noDoc",noDoc)%>
					<%=fb.hidden("beginSearch","")%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader">
				<td width="12%">&nbsp;AUD User</td>
				<td width="13%" align="center">AUD Fecha</td>
				<td width="7%" align="center">AUD Acci&oacute;n</td>
				<%
					for (int t = 0; t<alTblTitle.size(); t++){
					String _title = (alTblTitle.get(t)).split("@@")[1];
					String _width = (alTblTitle.get(t)).split("@@")[2];
					String _align = (alTblTitle.get(t)).split("@@")[3];
					%>
					 <td width="<%=_width%>%" align="<%=_align%>"><%=_title%></td>
				<%
				}
				%>
			</tr>
			<%  String fieldNum = "", groupName = "", groupName1 = "", groupName2 = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";

					if (cdo.getColValue("fieldGr") != null && !groupName.equalsIgnoreCase(cdo.getColValue("fieldGr")))
					{
				%>
				<tr class="TextHeader01">
					<td colspan="13">&nbsp;<%=cdo.getColValue("fieldGr")%></td>
				</tr>
			<%
					}
			%>

			<%if (cdo.getColValue("fieldGr1") != null && !groupName1.equalsIgnoreCase(cdo.getColValue("fieldGr1"))){%>
					<tr class="TextHeader02">
					<td colspan="<%=alTblTitle.size()+3%>">&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("fieldGr1")%></td>
				</tr>
			<%}%>

			<%if (cdo.getColValue("fieldGr2") != null && !groupName2.equalsIgnoreCase(cdo.getColValue("fieldGr2"))){%>
					<tr class="TextHeader02">
					<td colspan="<%=alTblTitle.size()+3%>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("fieldGr2")%></td>
				</tr>
			<%}%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;<%=cdo.getColValue("aud_webuser_ip")%></td>
					<td align="center"><%=cdo.getColValue("aud_timestamp")%></td>
					<td align="center"><%=cdo.getColValue("aud_action_desc")%></td>
					<%
						for (int t = 0; t<alTblTitle.size(); t++){
							String _align = (alTblTitle.get(t)).split("@@")[3];
							fieldNum = (alTblTitle.get(t)).split("@@")[0];
					%>
						<td align="<%=_align%>"><%=cdo.getColValue("field"+fieldNum)%></td>
					<%}%>
				</tr>
				<%
				groupName = cdo.getColValue("fieldGr");
				groupName1 = cdo.getColValue("fieldGr1");
				groupName2 = cdo.getColValue("fieldGr2");
				}
				%>

</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("process",process)%>
				<%=fb.hidden("from_date",fromDate)%>
				<%=fb.hidden("to_date",toDate)%>
				<%=fb.hidden("user_name",userName)%>
				<%=fb.hidden("idDoc",idDoc)%>
				<%=fb.hidden("noDoc",noDoc)%>
				<%=fb.hidden("beginSearch","")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel>&nbsp;<%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>&nbsp;<%=pVal%>&nbsp;<cellbytelabel id="7">hasta</cellbytelabel>&nbsp;<%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("process",process)%>
					<%=fb.hidden("from_date",fromDate)%>
						<%=fb.hidden("to_date",toDate)%>
					<%=fb.hidden("user_name",userName)%>
					<%=fb.hidden("idDoc",idDoc)%>
					<%=fb.hidden("noDoc",noDoc)%>
					<%=fb.hidden("beginSearch","")%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}
%>
