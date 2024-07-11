<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.service.HTTPClientHandler"%>
<%@ page import="issi.admin.IFRestClient"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%!
String getIndexMessage(String responseText,int index)
{
	String flag="";
	String[] responseArr = responseText.split("\\|");
	if(responseArr!=null && responseArr.length>=index) {flag=responseArr[index].trim();}
	return flag;
}
boolean checkPrinter(String url)
{
	boolean flag=false;
	HTTPClientHandler httpClient=new HTTPClientHandler();
	String urlDgi=url+"/ifserver/ifserver.php?service=CHECKPRINTER";
	String responseText = httpClient.getHttpResponse(urlDgi);
	flag=(getIndexMessage((responseText==null ? "":responseText),2)).equals("1") ? true:false;
	return flag;
}
String getSerialNumber(String url)
{
	String flag="";
	HTTPClientHandler httpClient=new HTTPClientHandler();
	String urlDgi=url+"/ifserver/ifserver.php?service=LASTNUM";
	String responseText = httpClient.getHttpResponse(urlDgi);
	flag=(getIndexMessage((responseText==null ? "":responseText),4));
	return flag;
}
String getLastDocNum(String responseText,String docType)
{
	String flag="";
	int ind=-1;
	if(docType!=null && docType.equals("FAC")) ind=1;
	if(docType!=null && docType.equals("NDC")) ind=2;
	if(docType!=null && docType.equals("NDD")) ind=3;
	String[] responseArr1 = responseText.split("@@");
	String[] responseArr = responseArr1[0].split("\\|");
	if(responseArr!=null && responseArr.length>=4) {flag=responseArr[0].trim()+"-"+responseArr[ind].trim();}
	return flag;
}
%>

<%
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer xtraNotes = new StringBuffer();
StringBuffer sbSql = new StringBuffer();
StringBuffer tSql = new StringBuffer();
StringBuffer tFilter = new StringBuffer();
String responseText="";
String errMsg="";
String fp = request.getParameter("fp");
String actType = request.getParameter("actType");
String docType = request.getParameter("docType");
String docId = request.getParameter("docId");
String docNo = request.getParameter("docNo");
String compania = request.getParameter("compania");
String tipo = request.getParameter("tipo");
String ruc = request.getParameter("ruc");
String dv = request.getParameter("dv");
String codigoDgi = request.getParameter("codigoDgi");
String id_lista = request.getParameter("id_lista");
String ip = (SecMgr.getParValue(UserDet,"DGI")!=null? SecMgr.getParValue(UserDet,"DGI"):"");

String url="http://"+(!ip.equals("")? ip:request.getRemoteHost());

if (docType.equalsIgnoreCase("DGI")) {//I M P R E S O R A   F I S C A L

	String printerFlag = "";
	IFRestClient printDGI = new IFRestClient();
	HTTPClientHandler httpClient=new HTTPClientHandler();
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fp="+fp+"&actType="+actType+"&docType="+docType+xtraNotes.toString());

	if (actType.equalsIgnoreCase("2")) {

		CommonDataObject cdo = new CommonDataObject();

		sbSql = new StringBuffer();
		sbSql.append("select nvl(get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'DGI_DOCUMENT_COPY_INT'),'0') as DGI_DOCUMENT_COPY_INT, nvl(get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'DGI_DOCUMENT_COPY'),'0') as DGI_DOCUMENT_COPY, nvl(get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'DGI_DOCUMENT_LIM_CAR'),'40') as DGI_DOCUMENT_LIM_CAR, nvl(get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'DGI_DOCUMENT_CASHDRAWER'),'N') as DGI_DOCUMENT_CASHDRAWER, nvl(get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'FAC_DGI_LABEL_CDST'),'0') as FAC_DGI_LABEL_CDST, nvl(get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'SHOW_CDSH_DGI'),'Y') as SHOW_CDSH_DGI from dual");
		CommonDataObject p = SQLMgr.getData(sbSql.toString());

		if(fp.equals("lista_envio")){

			if (request.getParameter("ruc_cedula")!=null && !request.getParameter("ruc_cedula").equals("")) {

				sbSql = new StringBuffer();
				sbSql.append("call sp_fac_dgi_upd_ruc_lista(");
				sbSql.append(id_lista);
				sbSql.append(", '");
				sbSql.append(IBIZEscapeChars.forSingleQuots(request.getParameter("ruc_cedula")));
				sbSql.append("', '");
				sbSql.append(IBIZEscapeChars.forSingleQuots(request.getParameter("nombre_2")));
				sbSql.append("')");
				//ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				//ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fp="+fp+"&actType="+actType+"&docType="+docType+xtraNotes);
				SQLMgr.execute(sbSql.toString());
				//ConMgr.clearAppCtx(null);

			}

			sbSql = new StringBuffer();
			sbSql.append("select compania, 'FAC' as tipo_docto, 'FACTHOSP' as tipo_docto_orig, 'N' as anulada, '' as oc, '0.00' as centrosterceros, '");
			sbSql.append(p.getColValue("DGI_DOCUMENT_COPY"));
			sbSql.append("' as dgi_copy, '");
			sbSql.append(p.getColValue("DGI_DOCUMENT_LIM_CAR"));
			sbSql.append("' as limite_car, '");
			sbSql.append(p.getColValue("DGI_DOCUMENT_CASHDRAWER"));
			sbSql.append("' as open_cashdrawer");

			//----->CONFIG
			int numCols = 3;
			sbSql.append(", ");
			sbSql.append(numCols);
			sbSql.append(" as num_cols, ' ' as labeled");

			//----->HEADER COMMENTS
			sbSql.append(", substr(decode(ruc_cedula,'RUC',to_char(lista_envio),ruc_cedula)||' DV:'||dv,0,@@maxChar) as clientRUC");
			sbSql.append(", substr(max(cliente),0,@@maxChar) as clientName");
			sbSql.append(", substr(max(decode(campo4,null,' ','Aseguradora:'||campo4)),0,");
			sbSql.append((numCols == 3)?"@@maxChar":"70");
			sbSql.append(") as clientAseg");
			sbSql.append(", substr('-',0,@@maxChar) as docRef");
			sbSql.append(", substr('-',0,@@maxChar) as clientAge");
			sbSql.append(", substr('-',0,@@maxChar) as clientDOB");
			sbSql.append(", substr('-',0,@@maxChar) as clientCategoria");
			sbSql.append(", substr('-',0,@@maxChar) as clientMedico");

			//----->TOTAL COMMENTS
			sbSql.append(", max(trim(campo9)) as printingFlag, 'S' as printingCopago");
			sbSql.append(", substr('-',0,@@maxChar) as totalCentrosTerceros");
			sbSql.append(", substr('Copago:'||trim(to_char(max((case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then getMontoCopago(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo)) else 0 end)),'999999999990.00')),0,@@maxChar) as totalCopago");
			sbSql.append(", substr(max(decode(campo4,null,' ',campo4)),0,@@maxChar) as clientAsegComplete");
			sbSql.append(", substr(' ',0,@@maxChar) as subTotalplusCIII");
			sbSql.append(", substr('',0,@@maxChar) as direccion1, substr('',(@@maxChar + 1),(@@maxChar * 2)) as direccion2");

			sbSql.append(", trim(to_char(sum(case when (case when tipo_docto in ('FACP','NCP','NDP') then 0 else nvl(descuento,0) + (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then getMontoCopagoHon(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo),'OT',null) else 0 end) end) > (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then (select sum(z.monto + z.descuento + z.descuento2) from tbl_fac_detalle_factura z, tbl_cds_centro_servicio y where z.fac_codigo = a.codigo and z.imprimir_sino = 'S' and z.centro_servicio = y.codigo and y.tipo_cds <> 'T' and y.codigo != (case when '");
			sbSql.append(p.getColValue("SHOW_CDSH_DGI"));
			sbSql.append("' = 'Y' then -100 else 0 end)) else 0 end) then (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then (select sum(z.monto + z.descuento + z.descuento2) from tbl_fac_detalle_factura z, tbl_cds_centro_servicio y where z.fac_codigo = a.codigo and z.imprimir_sino = 'S' and z.centro_servicio = y.codigo and y.tipo_cds <> 'T' and y.codigo != (case when '");
			sbSql.append(p.getColValue("SHOW_CDSH_DGI"));
			sbSql.append("' = 'Y' then -100 else 0 end)) else 0 end) else (case when tipo_docto in ('FACP','NCP','NDP') then 0 else nvl(descuento,0) + (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then getMontoCopagoHon(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo),'OT',null) else 0 end) end) end),'999999999990.00')) as totalDiscount");

			sbSql.append(" from tbl_fac_dgi_documents a where nvl(impreso,'N') = 'N' and exists (select null from tbl_fac_lista_envio_det led where led.compania = a.compania and led.factura = a.codigo and led.estado = 'A' and exists (select null from tbl_fac_lista_envio le where le.compania = led.compania and le.id = led.id and le.id = ");
			sbSql.append(id_lista);
			sbSql.append(")) group by compania, lista_envio, ruc_cedula, dv");
			cdo = SQLMgr.getData(sbSql.toString().replaceAll("@@maxChar",p.getColValue("DGI_DOCUMENT_LIM_CAR")));
			cdo.addColValue("tipo_Doc", "FAC");

			sbSql = new StringBuffer();
			sbSql.append("select compania, ");
			sbSql.append(id_lista);
			sbSql.append(", /*trim (to_char (sum (case when (case when tipo_docto in ('FACP', 'NCP', 'NDP') then 0 else nvl (descuento, 0) + (case when tipo_docto = 'FACT' or substr (codigo, 1, 2) = 'A-' then getmontocopagohon (compania, decode (substr (codigo, 1, 2), 'A-', substr (codigo, 3), codigo), 'OT', null) else 0 end) end) > (case when tipo_docto = 'FACT' or substr (codigo, 1, 2) = 'A-' then (select sum (z.monto + z.descuento + z.descuento2) from tbl_fac_detalle_factura z, tbl_cds_centro_servicio y where z.fac_codigo = a.codigo and z.imprimir_sino = 'S' and z.centro_servicio = y.codigo and y.tipo_cds <> 'T' and y.codigo != (case when get_sec_comp_param ( -1, 'SHOW_CDSH_DGI') = 'Y' then -100 else 0 end)) else 0 end) then (case when tipo_docto = 'FACT' or substr (codigo, 1, 2) = 'A-' then (select sum (z.monto + z.descuento + z.descuento2) from tbl_fac_detalle_factura z, tbl_cds_centro_servicio y where z.fac_codigo = a.codigo and z.imprimir_sino = 'S' and z.centro_servicio = y.codigo and y.tipo_cds <> 'T' and y.codigo != (case when get_sec_comp_param ( -1, 'SHOW_CDSH_DGI') = 'Y' then -100 else 0 end)) else 0 end) else (case when tipo_docto in ('FACP', 'NCP', 'NDP') then 0 else nvl (descuento, 0) + (case when    tipo_docto = 'FACT' or substr (codigo, 1, 2) = 'A-' then getmontocopagohon (compania, decode (substr (codigo, 1, 2), 'A-', substr (codigo, 3), codigo), 'OT', null) else 0 end) end) end), '999999999990.00'))*/'0' as discount, coalesce((select comentario from tbl_fac_lista_envio where compania = a.compania and id = a.lista_envio), 'Paquetes Corporativos '||(select count(*) from tbl_fac_lista_envio_det where estado = 'A' and compania = a.compania and id = a.lista_envio)||' Pacientes') itemname, to_char (1, '999999999990.000') itemqty, to_char (sum((select sum(precio) from tbl_fac_dgi_docto_det dd where dd.compania = a.compania and dd.id = a.id)), '999999999990.' || nvl ( (select co.no_dec_dgi from tbl_sec_compania co where co.codigo = a.compania), 99)) itemunitprice, 0 taxPerc from tbl_fac_dgi_documents a where nvl(impreso, 'N') = 'N' and a.tipo_docto = 'FACT' and exists (select null from tbl_fac_lista_envio_det led where led.compania = a.compania and led.factura = a.codigo and led.estado = 'A' and exists (select null from tbl_fac_lista_envio le where le.compania = led.compania and le.id = led.id and le.id = ");
			sbSql.append(id_lista);
			sbSql.append(")) group by compania, lista_envio ");
			al = SQLMgr.getDataList(sbSql.toString());

		} else {

			if (request.getParameter("ruc_cedula")!=null && !request.getParameter("ruc_cedula").equals("")) {

				sbSql = new StringBuffer();
				sbSql.append("call sp_fac_dgi_upd_ruc(");
				sbSql.append(docId);
				sbSql.append(", '");
				sbSql.append(IBIZEscapeChars.forSingleQuots(request.getParameter("ruc_cedula")));
				sbSql.append("', '");
				sbSql.append(IBIZEscapeChars.forSingleQuots(request.getParameter("nombre_2")));
				sbSql.append("')");
				//ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				//ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fp="+fp+"&actType="+actType+"&docType="+docType+xtraNotes);
				SQLMgr.execute(sbSql.toString());
				//ConMgr.clearAppCtx(null);

			}

			//if (id == null) throw new Exception("El Código no es válido. Por favor intente nuevamente!");
			sbSql = new StringBuffer();
			sbSql.append("select id, compania, decode(tipo_docto,'ND','NDD','NC','NDC','FACT','FAC','FACP','FAC','NCP','NDC','NDP','NDD',tipo_docto) as tipo_docto, (case when tipo_docto in ('ND','NC','FACT') then 'FACTHOSP' else 'FACTPOS' end) as tipo_docto_orig, anio, trim(to_char(nvl(monto,0),'999999999990.00')) as monto, nvl(impuesto,0) as impuesto, to_char(fecha,'dd/mm/yyyy') as fecha, usuario_creacion, fecha_creacion, (case when tipo_docto in ('NC','ND') then getDGICodigo(compania,cod_ref) else cod_ref end) as refFactura, tipo_docto_ref, nvl(impreso,'N') as impreso, identificacion, codigo_dgi, dv, campo3, campo7, checkfactanulada(compania,codigo,tipo_docto) as anulada, trim(campo10) as oc, '0.00' as centrosTerceros, cod_ref, tipo_docto as tipo_doc");
			sbSql.append(", decode(a.interfaz_far,'S','");
			sbSql.append(p.getColValue("DGI_DOCUMENT_COPY_INT"));
			sbSql.append("','");
			sbSql.append(p.getColValue("DGI_DOCUMENT_COPY"));
			sbSql.append("') as dgi_copy, '");
			sbSql.append(p.getColValue("DGI_DOCUMENT_LIM_CAR"));
			sbSql.append("' as limite_car, '");
			sbSql.append(p.getColValue("DGI_DOCUMENT_CASHDRAWER"));
			sbSql.append("' as open_cashdrawer");

			//----->CONFIG
			int numCols = 3;
			sbSql.append(", ");
			sbSql.append(numCols);
			sbSql.append(" as num_cols");
			// valor (incluyendo etiqueta) sin truncar (IFClient se encargará de truncar)
			sbSql.append(", ' ' as labeled");//if label is append to value, if not the comment this line

			//----->HEADER COMMENTS
			sbSql.append(", substr(decode(ruc_cedula,'RUC',to_char(id),ruc_cedula)||' DV:'||dv,0,@@maxChar) as clientRUC"); // se agrego en RUC sin comando de abrir cashdrawer
			//sbSql.append(", substr(ruc_cedula,0,@@maxChar)||'@@0' as clientRUC"); // se agrego en RUC comando de abrir cashdrawer eso se aplica cuando ya cash drawer esta conectado a impresora fiscal
			sbSql.append(", substr(cliente,0,@@maxChar) as clientName");
			sbSql.append(", substr((case when tipo_docto in ('FACP','NCP','NDP') or facturar_a = 'O' then nvl(campo8,' ') else decode(campo4,null,' ','Aseguradora:'||campo4) end),0,");
			sbSql.append((numCols == 3)?"@@maxChar":"70");
			sbSql.append(") as clientAseg");
			sbSql.append(", substr(decode(codigo,null,' ','Referencia:'||codigo),0,@@maxChar) as docRef");
			sbSql.append(", substr(decode(cliente, nombre_2,decode(campo5,null,' ','Edad:'||(select edad from vw_adm_paciente where pac_id = a.pac_id)||decode(nvl(trim(campo9),'N'),'N',' ','S',' '||trim(campo10))),'Pac.: '||nombre_2),0,@@maxChar) as clientAge");
			sbSql.append(", substr(decode(campo6,null,' ','Fecha Nacimiento:'||case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = a.pac_id) else campo6 end),0,@@maxChar) as clientDOB");
			sbSql.append(", substr(decode(campo1,null,' ','Categoria:'||campo1),0,@@maxChar) as clientCategoria");
			sbSql.append(", substr(decode(campo2,null,' ','Medico:'||campo2),0,@@maxChar) as clientMedico");

			//----->TOTAL COMMENTS
			sbSql.append(", trim(campo9) as printingFlag, (case when (tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-') and nvl(getMontoCopago(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo)),0) = 0 and facturar_a = 'P' then 'N' when facturar_a = 'O' then 'N' else 'S' end) as printingCopago");
			sbSql.append(", substr((case when tipo_docto in ('FACT') or substr(codigo,1,2) = 'A-' then getMontoCentroTercero(decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo),compania) else '-' end),0,@@maxChar) as totalCentrosTerceros");
			sbSql.append(", substr('Copago:'||trim(to_char((case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then getMontoCopago(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo)) else 0 end),'999999999990.00')),0,@@maxChar) as totalCopago");
			sbSql.append(", substr(decode(campo4,null,' ',campo4),0,@@maxChar) as clientAsegComplete");
			sbSql.append(", substr((case when tipo_docto in ('FACT') or substr(codigo,1,2) = 'A-' then decode('");
			sbSql.append(p.getColValue("FAC_DGI_LABEL_CDST"));
			sbSql.append("','0','TOTAL+CDST:',lpad('A PAGAR:',@@maxChar - length(trim(to_char(gettotalfactura(codigo,compania),'999,990.00'))),'_'))||trim(to_char(gettotalfactura(codigo,compania),'999,990.00')) else ' ' end),0,@@maxChar) as subTotalplusCIII");
			sbSql.append(", substr(campo11,0,@@maxChar) as direccion1, substr(campo11,(@@maxChar + 1),(@@maxChar * 2)) as direccion2");

			//sbSql.append(", trim(to_char((case when tipo_docto in ('FACP','NCP','NDP') then 0 else nvl(descuento,0) + (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then getMontoCopagoHon(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo),'OT',null) else 0 end) end),'999999999990.00')) as totalDiscount");
			sbSql.append(", trim(to_char(case when (case when tipo_docto in ('FACP','NCP','NDP') then 0 else nvl(descuento,0) + (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then getMontoCopagoHon(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo),'OT',null) else 0 end) end) > (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then (select sum(z.monto + z.descuento + z.descuento2) from tbl_fac_detalle_factura z, tbl_cds_centro_servicio y where z.fac_codigo = a.codigo and z.imprimir_sino = 'S' and z.centro_servicio = y.codigo and y.tipo_cds <> 'T' and y.codigo != (case when '");
			sbSql.append(p.getColValue("SHOW_CDSH_DGI"));
			sbSql.append("' = 'Y' then -100 else 0 end)) else 0 end) then (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then (select sum(z.monto + z.descuento + z.descuento2) from tbl_fac_detalle_factura z, tbl_cds_centro_servicio y where z.fac_codigo = a.codigo and z.imprimir_sino = 'S' and z.centro_servicio = y.codigo and y.tipo_cds <> 'T' and y.codigo != (case when '");
			sbSql.append(p.getColValue("SHOW_CDSH_DGI"));
			sbSql.append("' = 'Y' then -100 else 0 end)) else 0 end) else (case when tipo_docto in ('FACP','NCP','NDP') then 0 else nvl(descuento,0) + (case when tipo_docto = 'FACT' or substr(codigo,1,2) = 'A-' then getMontoCopagoHon(compania,decode(substr(codigo,1,2),'A-',substr(codigo,3),codigo),'OT',null) else 0 end) end) end,'999999999990.00')) as totalDiscount");

			sbSql.append(" from tbl_fac_dgi_documents a where id = ");
			sbSql.append(docId);
			cdo = SQLMgr.getData(sbSql.toString().replaceAll("@@maxChar",p.getColValue("DGI_DOCUMENT_LIM_CAR")));

			if (cdo.getColValue("anulada").equalsIgnoreCase("S")) throw new Exception("La factura #"+docId+" fue ANULADA previamente! No puede imprimirla!");
			else if (cdo.getColValue("impreso").equalsIgnoreCase("Y")) throw new Exception("La factura #"+docId+" ya fue IMPRESA previamente! Si requiere imprimir una copia tendrá que utilizar la opción de RE-IMPRIMIR!");

			sbSql = new StringBuffer();
			sbSql.append("select id, tipo_docto, compania, anio, codigo_trx, codigo,  descripcion/*substr(,0,40)*/ itemName, to_char(nvl(cantidad, 1), '999999999990.000') itemQty, to_char(precio, '999999999990.'||NVL((SELECT co.no_dec_dgi FROM TBL_SEC_COMPANIA co WHERE co.codigo = dd.compania), 99)) itemUnitPrice, nvl(impuesto, 0)impuesto, nvl(taxPerc,0)taxPerc, (case when tipo_docto in ('FACP', 'NCP', 'NDP') then to_char(nvl(descuento, 0), '9999990.99') else '0' end )as discount, usuario_creacion from tbl_fac_dgi_docto_det dd where id = ");
			sbSql.append(docId);
			if(cdo.getColValue("tipo_docto_orig").equals("FACTHOSP")){
				sbSql.append(" and exists (select null from tbl_cds_centro_servicio cds where cds.tipo_cds != 'T' and cds.codigo != 0 and (to_char(cds.codigo) = dd.codigo or dd.codigo is null))");
			}
			al = SQLMgr.getDataList(sbSql.toString());

			if(al.size()==0 && cdo.getColValue("tipo_docto_orig").equals("FACTHOSP")){

				sbSql = new StringBuffer();
				sbSql.append("select 0 codigo, 'CENTROS TERCEROS' itemName, to_char(1, '999999999990.000') itemQty, to_char(0, '999999999990.00') itemUnitPrice, 0 impuesto, 0 taxPerc, 0 as discount from dual");
				al = SQLMgr.getDataList(sbSql.toString());

			}

			if (!cdo.getColValue("centrosTerceros").equals("0.00") && al.size() == 0) throw new Exception("La Factura no se puede imprimir porque el Monto corresponde a Centros Terceros!");

		}

		String  sendCmds = "";
		tipo=cdo.getColValue("tipo_docto");
		String cmdsFP = "";
		if(cdo.getColValue("tipo_Doc").equals("FACP")){

			sbSql = new StringBuffer();
			sbSql.append("select trim(getFormasPago(");
			sbSql.append((String) session.getAttribute("_companyId"));
			sbSql.append(", ");
			sbSql.append(cdo.getColValue("cod_ref"));
			sbSql.append(")) formas_pago from dual");
			CommonDataObject cdFP = SQLMgr.getData(sbSql.toString());
			if(cdFP!=null) {
				//cmdsFP = "@@201" + printDGI.getFloatSubString(cdFP.getColValue("formas_pago"),12,"0");
				cmdsFP = cdFP.getColValue("formas_pago");
			}

		}
		System.err.println(" ---------------> tipo_docto="+cdo.getColValue("tipo_docto"));
		issi.admin.ISSILogger.error("dgi",request.getContextPath()+request.getServletPath()+" ---------------> tipo_docto="+cdo.getColValue("tipo_docto"));
		String cashdrawerCmd = "";
		//if ((cdo.getColValue("open_cashdrawer").equalsIgnoreCase("s") || cdo.getColValue("open_cashdrawer").equalsIgnoreCase("y")) && request.getParameter("touch") != null && request.getParameter("touch").equalsIgnoreCase("y")) cashdrawerCmd = "0@@";
		if(cdo.getColValue("tipo_docto").equals("FAC")) sendCmds = cashdrawerCmd+printDGI.printInvoice(cdo,al);
		else if(cdo.getColValue("tipo_docto").equals("NDD")) sendCmds = printDGI.printNDD(cdo,al);
		else if(cdo.getColValue("tipo_docto").equals("NDC")) sendCmds = printDGI.printNDC(cdo,al);
		System.err.println(sendCmds);
		issi.admin.ISSILogger.error("dgi",request.getContextPath()+request.getServletPath()+" "+sendCmds);
		if(checkPrinter(url)){

			String urlDgi="";
			if ((cdo.getColValue("open_cashdrawer").equalsIgnoreCase("s") || cdo.getColValue("open_cashdrawer").equalsIgnoreCase("y")) && request.getParameter("touch") != null && request.getParameter("touch").equalsIgnoreCase("y")) {

				urlDgi=url+"/ifserver/ifserver.php?service=PRINTFDOC&docType=FAC&sendCommands=0";
				issi.admin.ISSILogger.info("dgi",urlDgi);
				responseText = httpClient.getHttpResponse(urlDgi);
				if (responseText != null || !responseText.trim().equals("")) errMsg+=getIndexMessage(responseText,0);
				Thread.sleep(300);

			}
			urlDgi=url+"/ifserver/ifserver.php?service=PRINTFDOC&docType="+tipo+"&sendCommands="+IBIZEscapeChars.forURL(sendCmds)+(cmdsFP.equals("")?"@@101":IBIZEscapeChars.forURL(cmdsFP));
			issi.admin.ISSILogger.info("dgi",urlDgi);
			responseText = httpClient.getHttpResponse(urlDgi);
			String _lastPrintedDocNo= (String) session.getAttribute("_lastPrintedDocNo");
			if(responseText!=null && responseText.equals(_lastPrintedDocNo)) {

				urlDgi=url+"/ifserver/ifserver.php?service=PRINTFDOC&docType="+tipo+"&sendCommands=7";
				responseText=httpClient.getHttpResponse(urlDgi);
				throw new Exception("Por favor, revisar Impresora.  El documento no fue impreso correctamente, intentar de nuevo..!");

			}
			System.err.println(_lastPrintedDocNo);
			issi.admin.ISSILogger.error("dgi",request.getContextPath()+request.getServletPath()+" Last Document Printed response "+_lastPrintedDocNo);
			issi.admin.ISSILogger.error("dgi",request.getContextPath()+request.getServletPath()+" Current Document Printed response "+responseText);
			session.setAttribute("_lastPrintedDocNo", responseText);
			if (responseText != null || !responseText.trim().equals("")) errMsg+=getIndexMessage(responseText,0);
			long startTime=System.currentTimeMillis() ;
			long endTime=System.currentTimeMillis()+2100 ;
			while(endTime<startTime) startTime=System.currentTimeMillis();
			//Thread.sleep(2100); // added sleep for 2.1 seconds bixolon was giving error
			String _lastDocNum = getLastDocNum(responseText,tipo);
			if (_lastDocNum!=null && !_lastDocNum.trim().equals("")) {

				sbSql = new StringBuffer();
				if(fp.equals("lista_envio")){

					sbSql.append("call sp_fac_dgi_upd_num_fact_lista(");
					sbSql.append(id_lista);
					sbSql.append(", '");
					sbSql.append(_lastDocNum);
					sbSql.append("')");

				} else {

					sbSql.append("call sp_fac_dgi_upd_num_fact(");
					sbSql.append(docId);
					sbSql.append(", '");
					sbSql.append(_lastDocNum);
					sbSql.append("')");

				}
				SQLMgr.execute(sbSql.toString());
				sbSql = new StringBuffer();

			}//update dgi number to document

			int nCopy = 0;
			try { nCopy = Integer.parseInt(cdo.getColValue("dgi_copy")); } catch (Exception ex) { System.out.println("* * * DGI_DOCUMENT_COPY ["+cdo.getColValue("dgi_copy")+"] invalid number! * * *"); }
			for (int i=1; i<=nCopy; i++) {

				urlDgi=url+"/ifserver/ifserver.php?service=PRINTFDOC&docType="+tipo+"&sendCommands="+IBIZEscapeChars.forURL("RU00000000000000");
				responseText = httpClient.getHttpResponse(urlDgi);
				if (responseText != null || !responseText.trim().equals("")) errMsg+=getIndexMessage(responseText,0);
				//printDGI.sendBatchCmd("RU00000000000000");//to reprint last document
				if (nCopy > 1 && i != nCopy) { System.out.println("Sleeping..."); Thread.sleep(2000); }

			}

		} else errMsg="IMPRESORA NO CONECTADO";

	} else if (actType.equalsIgnoreCase("3")) {

		if (url!=null && !url.equals("")) {

			boolean checkPrinter=false;
			String urlDgi="";
			checkPrinter=checkPrinter(url);
			if(checkPrinter){

				urlDgi=url+"/ifserver/ifserver.php?service=REPORTEZ";
				responseText = httpClient.getHttpResponse(urlDgi);
				if (responseText != null || !responseText.trim().equals("")) errMsg+=getIndexMessage(responseText,0);
				//if (!printerFlag) throw new Exception("La impresión del Corte Z no se realizó!");

				long startTime = System.currentTimeMillis();
				long endTime = System.currentTimeMillis() + 1000;
				while (endTime < startTime) startTime = System.currentTimeMillis();

			} else errMsg="IMPRESORA NO CONECTADO";

		} else throw new Exception("Por favor, revisar Impresora.  Si los problemas persisten debe reiniciar el IFServer de impresora fiscal en la PC local..!");

	} else if (actType.equalsIgnoreCase("4")) {

		if (url!=null && !url.equals("")) {

			boolean checkPrinter=false;
			String urlDgi="";
			checkPrinter=checkPrinter(url);
			if(checkPrinter){

				urlDgi=url+"/ifserver/ifserver.php?service=REPORTEX";
				responseText = httpClient.getHttpResponse(urlDgi);
				if (responseText != null || !responseText.trim().equals("")) errMsg+=getIndexMessage(responseText,0);
				System.err.println("_________________________"+getIndexMessage(responseText,0));
				//if (!printerFlag) throw new Exception("La impresión del Corte X no se realizó!");

				long startTime = System.currentTimeMillis();
				long endTime = System.currentTimeMillis() + 1000;
				while (endTime < startTime) startTime = System.currentTimeMillis();

			}else errMsg="IMPRESORA NO CONECTADO";

		} else throw new Exception("Por favor, revisar Impresora.  Si los problemas persisten debe reiniciar el IFServer de impresora fiscal en la PC local..!");

	} else if (actType.equalsIgnoreCase("5")) {

		if(!docId.equals("0")){

			sbSql = new StringBuffer();
			sbSql.append("select case when a.tipo_docto in ('ND','NDP') then 'NDD' when a.tipo_docto in ('NC','NCO','NCP') then 'NDC' when a.tipo_docto in ('FACT','FACO','FACP') then 'FAC' else a.tipo_docto end as tipo_docto, substr(a.codigo_dgi,0,instr(a.codigo_dgi,'-') - 1) as num_serie, substr(a.codigo_dgi,instr(a.codigo_dgi,'-') + 1) as factura_dgi, nvl(a.campo8,'0.00') as totalCentrosTerceros, checkfactanulada(a.compania,a.codigo,a.tipo_docto) as anulada, (select count(*) from tbl_fac_dgi_docto_det where id = a.id) as nItems from tbl_fac_dgi_documents a where a.id = ");
			sbSql.append(docId);

			CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
			if (cdo.getColValue("anulada").equalsIgnoreCase("S")) throw new Exception("La factura fue Anulada previamente! No puede imprimirla!");
			else if (!cdo.getColValue("totalCentrosTerceros").equals("0.00") && cdo.getColValue("nItems").equals("0")) throw new Exception("La Factura no se puede imprimir porque el Monto corresponde a Centros Terceros!");

			if (checkPrinter(url)) {

				if (!getSerialNumber(url).equals(cdo.getColValue("num_serie"))) throw new Exception("Este documento no fue impreso en esta impresora!");
				String urlDgi=url+"/ifserver/ifserver.php?service=REPRINT&docType="+cdo.getColValue("tipo_docto")+"&refNumber="+cdo.getColValue("factura_dgi");
				responseText = httpClient.getHttpResponse(urlDgi);
				if (responseText == null || responseText.trim().equals("")) errMsg+=getIndexMessage(responseText,0);
				System.err.println("_________________________"+getIndexMessage(responseText,0));
				/*printerFlag = (getIndexMessage(responseText,2).equals("1")) ? true:false;
				if (!printerFlag) throw new Exception("La re-impresión no se realizó!");

				long startTime = System.currentTimeMillis();
				long endTime = System.currentTimeMillis() + 2000;
				while (endTime < startTime) startTime = System.currentTimeMillis();*/

			} else throw new Exception("Por favor, revisar Impresora.  Si los problemas persisten debe reiniciar el IFServer de impresora fiscal en la PC local.!");

		} else {

			if (checkPrinter(url)) {

				String urlDgi=url+"/ifserver/ifserver.php?service=PRINTFDOC&docType=REPRINTLAST&sendCommands="+IBIZEscapeChars.forURL("RU00000000000000");
				responseText = httpClient.getHttpResponse(urlDgi);
				if (responseText == null || responseText.trim().equals("")) errMsg+=getIndexMessage(responseText,0);
				System.err.println("_________________________"+getIndexMessage(responseText,0));
				/*printerFlag = (getIndexMessage(responseText,2).equals("1")) ? true:false;
				if (!printerFlag) throw new Exception("La re-impresión no se realizó!");

				long startTime = System.currentTimeMillis();
				long endTime = System.currentTimeMillis() + 2000;
				while (endTime < startTime) startTime = System.currentTimeMillis();*/

			} else throw new Exception("Por favor, revisar Impresora.  Si los problemas persisten debe reiniciar el IFServer de impresora fiscal en la PC local.!");

		}

	} else if (actType.equalsIgnoreCase("6")) {

		if (!docId.trim().equals("")) {

			sbSql = new StringBuffer();
			sbSql.append("call sp_fac_dgi_revert_num_fact(");
			sbSql.append(docId);
			sbSql.append(")");
			SQLMgr.execute(sbSql.toString());

		}

	} else if (actType.equalsIgnoreCase("52")) {

		if (request.getParameter("codigo_correcto") != null && !request.getParameter("codigo_correcto").trim().equals("")) {

			sbSql = new StringBuffer();
			sbSql.append("call sp_fac_dgi_corrige_num_fact(");
			sbSql.append(docId);
			sbSql.append(", '");
			sbSql.append(request.getParameter("codigo_correcto"));
			sbSql.append("', '");
			sbSql.append(codigoDgi);
			sbSql.append("', '");
			sbSql.append(IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));
			sbSql.append("', ");
			if(request.getParameter("impreso") != null && !request.getParameter("impreso").trim().equals("")) {
				sbSql.append("'");
				sbSql.append(request.getParameter("impreso"));
				sbSql.append("'");
			} else sbSql.append("null");

			sbSql.append(")");
			SQLMgr.execute(sbSql.toString());
			System.out.println("sbSql.........................................................................="+sbSql.toString());

		}

	} else if (actType.equalsIgnoreCase("55")) {

		/*if (printDGI.checkPrinter()) {

			//printerFlag = printDGI.printListDoc(tipo,transDesde,transHasta);
			if(fg.trim().equals("LIST"))printerFlag = printDGI.printListDoc(tipo,transDesde,transHasta);
			else printerFlag = printDGI.reprintDocument(tipo,fg,transDesde,transHasta,ruc);

			//reprintDocument(String tipo, String tipoFiltro, String desde,String hasta,String clientRUC)
			if (!printerFlag) throw new Exception("La re-impresión no se realizó!");

			long startTime = System.currentTimeMillis();
			long endTime = System.currentTimeMillis() + 2000;
			while (endTime < startTime) startTime = System.currentTimeMillis();

		} else throw new Exception("Por favor, revisar Impresora.  Si los problemas persisten debe reiniciar el IFServer de impresora fiscal en la PC local.!");*/

	}

}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<script language="javascript">
document.title = 'Impresion Fiscal ';
</script>
</head>
<body >
<div id="responseDiv">Por favor esperar estas imprimiendo el documento..... </br>

</div>
<script language="javascript">
function doSomething(val1,val2){
document.getElementById("responseDiv").innerHTML="Respuesta de Impresora Fiscal " + val1 +"<br>"+val2;
<% if(request.getParameter("fp")!=null && request.getParameter("fp").equals("facturarpos")){ %>
parent.closeWindow();
<% }else if(request.getParameter("fp")!=null && (request.getParameter("fp").equals("docto_dgi_list")) || request.getParameter("fp").equals("lista_envio")) { %>
parent.window.location.reload(true);
<% } %>
parent.hidePopWin(false);
}
<% if (errMsg.trim().equals("") || errMsg.equalsIgnoreCase("IMPRESORA NO CONECTADO")) { %>
doSomething('<%=errMsg%>','<%=responseText%>');
<% } else { %>
setTimeout(doSomething('<%=errMsg%>','<%=responseText%>'), 5000);
<% } %>
</script>
</body>
</html>