<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.pos.Marbete"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="CAFMgr" scope="page" class="issi.pos.CafeteriaMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htPM" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
SQLMgr.setConnection(ConMgr);
CmnMgr.setConnection(ConMgr);
CAFMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

String creatorId = UserDet.getUserEmpId();

String mode=request.getParameter("mode");
String change=request.getParameter("change");
String type=request.getParameter("type");
String compId=(String) session.getAttribute("_companyId");
String doc_id = request.getParameter("doc_id");
String pac_id = request.getParameter("pac_id");
String admision = request.getParameter("admision");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");

CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();
ArrayList alBK = new ArrayList();
if(mode==null) mode="add";
boolean viewMode=false;
if(mode.equals("view")) viewMode=true;
if(fp==null) fp="";
if(fg==null) fg="";
if (change == null) change = "0";
if (type == null) type = "0";
htPM.clear();
String key = "";
StringBuffer sbSql = new StringBuffer();
//htDet.clear();
if(request.getMethod().equalsIgnoreCase("GET")){
	if(fp.equals("POS")){
		if (htDet.size() > 0) alBK = CmnMgr.reverseRecords(htDet, false);
		for (int i=0; i<htDet.size(); i++){
			key = alBK.get(i).toString();
			CommonDataObject _cdo = (CommonDataObject) htDet.get(key);
			_cdo.addColValue("line_no", ""+(i+1));
			_cdo.addColValue("codigo", _cdo.getColValue("codigo"));
			_cdo.addColValue("descripcion", _cdo.getColValue("descripcion"));
			_cdo.addColValue("fecha_expira", "");
			_cdo.addColValue("system_date", CmnMgr.getCurrentDate("dd/mm/yyyy"));
			_cdo.addColValue("client_name", request.getParameter("client_name"));
			_cdo.addColValue("cod_barra", _cdo.getColValue("cod_barra"));
			_cdo.addColValue("cod_articulo", _cdo.getColValue("cod_articulo"));
			if(!_cdo.getColValue("codigo").contains("@D@")) al.add(_cdo);
			System.out.println("adding to marbete.........."+_cdo.getColValue("codigo")+" "+_cdo.getColValue("cod_barra"));
		}
	} else if(fp.equals("FAR")){
		sbSql.append("select f.id sec_orden, f.id, to_char(f.fecha_creacion, 'dd/mm/yyyy') doc_date, f.pac_id, (select nombre_paciente from vw_adm_paciente p where p.pac_id = f.pac_id) client_name, (select primer_nombre || decode(segundo_nombre, null, '', ' ' || segundo_nombre) || decode(primer_apellido, null, '', ' ' || primer_apellido) || decode(sexo, 'F', decode(apellido_de_casada, null, decode(segundo_apellido, null, '', ' ' || segundo_apellido), ' DE ' || apellido_de_casada), decode(segundo_apellido, null, '', ' ' || segundo_apellido)) from tbl_adm_medico med where exists (select null from tbl_adm_admision adm where adm.medico = med.codigo and adm.pac_id = f.pac_id and adm.secuencia = f.admision)) doctor, to_char(sysdate, 'dd/mm/yyyy') fecha, f.codigo_articulo codigo, f.descripcion as descripcion, a.cod_barra, '' fecha_expira, '' dosis, to_char(sysdate, 'dd/mm/yyyy') system_date, 0 line_no, 0 id, (select (case when get_sec_comp_param(f.compania,'FAR_MARBETE_SAVE_LOCATION_ADM_TYPE') in ('-',b.adm_type) then (select cds.descripcion from tbl_cds_centro_servicio cds where cds.codigo = a.centro_servicio) || (select case when habitacion is not null or cama is not null then ' [H.: '||habitacion || ' C.: '||cama || ']' end from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia and rownum = 1) else ' ' end) from tbl_adm_admision a, tbl_adm_categoria_admision b where a.categoria = b.codigo and a.secuencia = f.admision and a.pac_id = f.pac_id) sala from tbl_int_orden_farmacia f, tbl_inv_articulo a, tbl_inv_familia_articulo fa, tbl_sal_detalle_orden_med od, tbl_sal_orden_medica o where ");
		sbSql.append(" od.orden_med = o.codigo and od.secuencia = o.secuencia and od.pac_id = o.pac_id and od.pac_id = f.pac_id and od.secuencia = f.admision and od.tipo_orden = f.tipo_orden and od.orden_med = f.orden_med and od.codigo = f.codigo ");
		sbSql.append(" and f.codigo_articulo = a.cod_articulo and f.compania = a.compania and a.compania = fa.compania and a.cod_flia = fa.cod_flia and fa.marbete = 'S' and f.estado = 'A' and f.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and f.other2 = ");
	sbSql.append(doc_id);
	sbSql.append(" and od.pac_id = ");
	sbSql.append(pac_id);
	sbSql.append(" and od.secuencia = ");
	sbSql.append(admision);
	sbSql.append(" and not exists (select null from tbl_fac_marbete m, tbl_fac_marbete_det md where m.compania = md.compania and m.id = md.id and tipo = 'OM' and m.doc_id = od.codigo_orden_med and f.id = md.sec_orden) ");
		al = SQLMgr.getDataList(sbSql.toString());
	} else if(fp.equals("RECETA")){
		sbSql.append("select zz.*, nvl (zz.cantidad, 0) - nvl (zz.tot_despachado, 0) as tot_pendiente from (select m.no_receta, nvl (m.invalido, 'N') invalido, nvl (m.despachado, 'N') despachado, (select comp_id_receta from tbl_sal_recetas where pac_id = m.pac_id and admision = m.admision and id_recetas = m.no_receta and rownum = 1) as comp_id_receta, m.secuencia as codigo, m.medicamento as descripcion, m.indicacion, m.dosis, m.duracion, m.cantidad, m.frecuencia, p.primer_nombre || ' ' || p.segundo_apellido as client_name, decode (e.sexo, 'F', 'DRA. ', 'DR. ') || e.primer_nombre || decode (e.segundo_nombre, null, '', ' ' || e.segundo_nombre) || ' ' || e.primer_apellido || decode (e.segundo_apellido, null, '', ' ' || e.segundo_apellido) || decode (e.sexo, 'F', decode (e.apellido_de_casada, null, '', ' ' || e.apellido_de_casada)) as doctor, e.codigo as registro_medico, (select count (*) from tbl_sal_recetas r where r.pac_id = m.pac_id and r.admision = m.admision and r.id_recetas = m.no_receta and r.status = 'P') as printed, nvl (m.despachado_comentario, ' ') as despachado_comentario, (select sum (cantidad) from tbl_sal_med_recetas_despach where pac_id = m.pac_id and admision = m.admision and secuencia_med = m.secuencia and no_receta = m.no_receta) as tot_despachado, to_char(sysdate, 'dd/mm/yyyy') fecha, m.no_receta as id, (select (case when get_sec_comp_param(a.compania,'FAR_MARBETE_SAVE_LOCATION_ADM_TYPE') in ('-',b.adm_type) then (select cds.descripcion from tbl_cds_centro_servicio cds where cds.codigo = a.centro_servicio) || (select case when habitacion is not null or cama is not null then ' [H.: '||habitacion || ' C.: '||cama || ']' end from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia and rownum = 1) else ' ' end) from tbl_adm_admision a, tbl_adm_categoria_admision b where a.categoria = b.codigo and a.secuencia = m.admision and a.pac_id = m.pac_id) sala, to_char(sysdate, 'dd/mm/yyyy') system_date, 0 as line_no, 'salida_medicamento' cod_barra, 0 as cod_articulo, m.secuencia as sec_orden, '' fecha_expira from tbl_sal_salida_medicamento m, tbl_adm_paciente p, tbl_adm_admision a, (select x.codigo, x.primer_nombre, x.segundo_nombre, x.primer_apellido, x.segundo_apellido, x.apellido_de_casada, x.sexo, nvl (z.descripcion, 'NO TIENE') as especialidad from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo = y.medico(+) and y.secuencia(+) = 1 and y.especialidad = z.codigo(+)) e where p.pac_id = m.pac_id and a.medico = e.codigo and a.pac_id = m.pac_id and a.secuencia = m.admision and m.pac_id = ");
	sbSql.append(pac_id);
	sbSql.append(" and m.admision = ");
	sbSql.append(admision);
	sbSql.append(" and m.no_receta = ");
	sbSql.append(doc_id);
	sbSql.append(" and not exists (select null from tbl_fac_marbete ma, tbl_fac_marbete_det md where ma.compania = md.compania and ma.id = md.id and tipo = 'REC' and ma.doc_id = m.no_receta and m.secuencia = md.sec_orden) ");
	sbSql.append(" order by m.no_receta) zz where zz.comp_id_receta is not null /*and nvl (zz.tot_despachado, 0) > 0*/");
		al = SQLMgr.getDataList(sbSql.toString());
	}  else {
		sbSql.append("select f.doc_id, to_char(f.doc_date, 'dd/mm/yyyy') doc_date, f.client_id, (case when f.pac_id is not null and f.admision is not null then (select nombre_paciente from vw_adm_paciente p where p.pac_id = f.pac_id) else f.client_name end) client_name, f.net_amount, f.printed_no, coalesce(md.doctor, (select primer_nombre || decode(segundo_nombre, null, '', ' ' || segundo_nombre) || decode(primer_apellido, null, '', ' ' || primer_apellido) || decode(sexo, 'F', decode(apellido_de_casada, null, decode(segundo_apellido, null, '', ' ' || segundo_apellido), ' DE ' || apellido_de_casada), decode(segundo_apellido, null, '', ' ' || segundo_apellido)) from tbl_adm_medico med where exists (select null from tbl_adm_admision adm where adm.medico = med.codigo and adm.pac_id = f.pac_id and adm.secuencia = f.admision))) doctor, to_char(md.fecha, 'dd/mm/yyyy') fecha, ti.codigo, /*a.tech_descripcion||'-'||*/ ti.descripcion as descripcion, a.cod_barra, to_char(md.fecha_expira, 'dd/mm/yyyy') fecha_expira, md.dosis, to_char(sysdate, 'dd/mm/yyyy') system_date, nvl(md.line_no, 0) line_no, nvl(md.id, 0) id, (select (case when get_sec_comp_param(f.company_id,'FAR_MARBETE_SAVE_LOCATION_ADM_TYPE') in ('-',b.adm_type) then (select cds.descripcion from tbl_cds_centro_servicio cds where cds.codigo = a.centro_servicio) || (select case when habitacion is not null or cama is not null then ' [H.: '||habitacion || ' C.: '||cama || ']' end from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia and rownum = 1) else ' ' end) from tbl_adm_admision a, tbl_adm_categoria_admision b where a.categoria = b.codigo and a.secuencia = f.admision and a.pac_id = f.pac_id) sala from tbl_fac_trx f, tbl_fac_trxitems ti, tbl_inv_articulo a, tbl_inv_familia_articulo fa, (select m.compania, m.doc_id, m.id, m.doctor, m.fecha, md.codigo, md.descripcion, md.fecha_expira, md.dosis, m.estado, md.line_no from tbl_fac_marbete m, tbl_fac_marbete_det md where m.compania = md.compania and m.doc_id = md.doc_id and m.id = md.id) md where ti.tipo_descuento is null and ti.codigo = a.cod_articulo and ti.compania = a.compania and a.compania = fa.compania and a.cod_flia = fa.cod_flia and fa.marbete = 'S' and f.company_id = ti.compania and f.doc_id = ti.doc_id and ti.compania = md.compania(+) and ti.doc_id = md.doc_id(+) and ti.codigo = md.codigo(+) and md.estado(+) = 'A' and f.company_id = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and f.doc_id = ");
	sbSql.append(doc_id);
		al = SQLMgr.getDataList(sbSql.toString());
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
null;
}

function doSubmit(valor){
	document.form1.baction.value=valor;
	if(valor=='Guardar' || valor=='Imprimir') if(form1Validation()) document.form1.submit();
}
function printMarbete(){
	 var qty2Print = $("#qty2Print").val();
	 if (!isInteger(qty2Print)) alert("Por favor indique solamente intero positivo!");
	 else abrir_ventana('../pos/print_marbete.jsp?idDoc=<%=doc_id%>&qtyToPrint='+qty2Print);
}
</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value=""></jsp:param>
</jsp:include>
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode", mode)%>
<%=fb.hidden("change", change)%>
<%=fb.hidden("baction", "")%>
<%=fb.hidden("fp", fp)%>
<%=fb.hidden("fg", fg)%>
<%=fb.hidden("doc_id", doc_id)%>
<%=fb.hidden("pac_id", pac_id)%>
<%=fb.hidden("admision", admision)%>
<%=fb.hidden("size", ""+al.size())%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextRow06">
				<td colspan="4" align="center">MARBETE
				<%if (!mode.trim().equals("add")){%>
				<authype type="2"><span style="float:right">
				Cant.:<%=fb.textBox("qty2Print","1",false,false,false,2,2,"Text10",null,"onFocus=this.select()")%>
				<%=fb.button("btnPrnt","Imprimir",true,false,null,null,"onClick=\"javascript:printMarbete();\"")%>
				</span></authype>
				<%}%>
				</td>
			</tr>
			<%
			String fecha_expira = "";
			for(int i=0;i<al.size();i++){
				cdo = (CommonDataObject) al.get(i);
				fecha_expira = "fecha_expira"+i;
				if(i==0){
				%>
			<%=fb.hidden("client_name", cdo.getColValue("client_name"))%>
			<%=fb.hidden("fecha", cdo.getColValue("fecha"))%>
			<%=fb.hidden("id", cdo.getColValue("id"))%>

			<tr class="TextRow01">
				<td align="right">Nombre:</td>
				<td colspan="3"><%=cdo.getColValue("client_name")%></td>
			</tr>
			<%if(cdo.getColValue("sala")!=null && !cdo.getColValue("sala").equals("")){%>
			<%=fb.hidden("sala", cdo.getColValue("sala"))%>
			<tr class="TextRow01">
				<td align="right">Sala:</td>
				<td colspan="3"><%=cdo.getColValue("sala")%></td>
			</tr>
			<%}%>
			<tr class="TextRow01">
				<td align="right">Fecha:</td>
				<td colspan="3"><%=cdo.getColValue("system_date")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Doctor:</td>
				<td colspan="3"><%=fb.textBox("doctor",cdo.getColValue("doctor"),false,false,false,60,60,"Text10",null,null)%></td>
			</tr>
				<%
				}
			%>
			<%=fb.hidden("line_no"+i, cdo.getColValue("line_no"))%>
			<%=fb.hidden("codigo"+i, cdo.getColValue("codigo"))%>
			<%=fb.hidden("descripcion"+i, cdo.getColValue("descripcion"))%>
			<%=fb.hidden(""+i, cdo.getColValue(""))%>
			<%=fb.hidden("cod_barra"+i, cdo.getColValue("cod_barra"))%>
			<%=fb.hidden("cod_articulo"+i, cdo.getColValue("cod_articulo"))%>
			<%=fb.hidden("sec_orden"+i, cdo.getColValue("sec_orden"))%>
			<tr class="TextRow01">
				<td colspan="4" align="center"><%=cdo.getColValue("codigo")+"-"+cdo.getColValue("descripcion")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Fecha Expira:</td>
				<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="<%=fecha_expira%>" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_expira")%>" />
				</jsp:include>
				</td>
				<td align="right">Dosis:</td>
				<td colspan="3"><%=fb.textBox("dosis"+i,cdo.getColValue("dosis"),false,false,false,60,60,"Text10",null,null)%></td>
			</tr>
		<%}%>
			<tr class="TextRow01">
				<td align="right">&nbsp;</td>
				<td>&nbsp;</td>
				<td align="right">Estado:</td>
				<td><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"),false,false,0,"Text10",null,null,"","")%></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right">
				<%if(fp.equals("POS")){%>
				<%=fb.button("save","Imprimir",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%} else {%>
				<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%}%>
				<%if(fp.equalsIgnoreCase("int_farmacia")){} else if(fp.equalsIgnoreCase("POS")){%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close();\"")%>
				<%} else if(fp.equalsIgnoreCase("FAR") && fg.equals("despachar")){%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close();\"")%>
				<%} else {%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
				<%}%>
				</td>
			</tr>
		</table>
		</td>
	</tr>
</table>
<%=fb.formEnd(true)%>
<%
%>
</body>
</html>
<%
} else if(request.getMethod().equalsIgnoreCase("post")) {
	String baction = request.getParameter("baction");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	cdo = new CommonDataObject();
	htPM.clear();
	cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
	cdo.addColValue("nombre_cliente", request.getParameter("client_name"));
	cdo.addColValue("doc_id", request.getParameter("doc_id"));
	cdo.addColValue("id", request.getParameter("id"));
	cdo.addColValue("fecha", request.getParameter("fecha"));
	if(request.getParameter("pac_id")!=null && !request.getParameter("pac_id").equals("")) cdo.addColValue("pac_id", request.getParameter("pac_id"));
	if(request.getParameter("admision")!=null && !request.getParameter("admision").equals("")) cdo.addColValue("admision", request.getParameter("admision"));
	if(request.getParameter("doctor")!=null) cdo.addColValue("doctor", request.getParameter("doctor"));
	if(request.getParameter("sala")!=null) cdo.addColValue("sala", request.getParameter("sala"));
	if(request.getParameter("fp")!=null && request.getParameter("fp").equals("FAR")) cdo.addColValue("tipo", "OM");
	else if(request.getParameter("fp")!=null && request.getParameter("fp").equals("RECETA")) cdo.addColValue("tipo", "REC");
	else cdo.addColValue("tipo", "FAC");

	cdo.addColValue("estado", request.getParameter("estado"));
	Marbete mar = new Marbete();

	int size = Integer.parseInt(request.getParameter("size"));
	al.clear();
	for(int i =0;i<size;i++){
		CommonDataObject cd = new CommonDataObject();
		cd.addColValue("compania", (String) session.getAttribute("_companyId"));
		cd.addColValue("doc_id", request.getParameter("doc_id"));
		cd.addColValue("line_no", request.getParameter("line_no"+i));
		cd.addColValue("codigo", request.getParameter("codigo"+i));
		cd.addColValue("descripcion", request.getParameter("descripcion"+i));
		cd.addColValue("cod_articulo", request.getParameter("cod_articulo"+i));
		if(request.getParameter("fecha_expira"+i)!=null && !request.getParameter("fecha_expira"+i).equals("")) cd.addColValue("fecha_expira", request.getParameter("fecha_expira"+i));
		if(request.getParameter("dosis"+i)!=null && !request.getParameter("dosis"+i).equals("")) cd.addColValue("dosis", request.getParameter("dosis"+i));
		if(request.getParameter("fp")!=null && (request.getParameter("fp").equals("FAR") || request.getParameter("fp").equals("RECETA")) && request.getParameter("sec_orden"+i)!=null && !request.getParameter("sec_orden"+i).equals("")) cd.addColValue("sec_orden", request.getParameter("sec_orden"+i));
		al.add(cd);
		cd.setKey((i+1));
		if(fp.equals("POS")){
			cd.addColValue("nombre_cliente", request.getParameter("client_name"));
			cd.addColValue("currrent_date", request.getParameter("fecha"));
			cd.addColValue("cod_barra", request.getParameter("cod_barra"+i));
			if(request.getParameter("doctor")!=null) cd.addColValue("doctor", request.getParameter("doctor"));
			htPM.put(cd.getKey(), cd);
			System.out.println("adding to marbete .... "+cd.getKey());
		}
	}
	mar.setAlDet(al);

	String returnId = "";
	System.out.println("baction="+request.getParameter("baction"));
	if (request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("Guardar")) {
		if (mode.equalsIgnoreCase("add")){
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			mar.setCdo(cdo);
			CAFMgr.addMarbete(mar);
			returnId = CAFMgr.getPkColValue("id");
		} else if (mode.equalsIgnoreCase("edit")){
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			mar.setCdo(cdo);
			CAFMgr.updMarbete(mar);
		}
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript" src="../js/global.js"></script>
<script language="javascript">
function closeWindow(){
<%
if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Imprimir")){%>
	window.location='../pos/print_marbete.jsp?fp=POS';
<%} else {
if(CAFMgr.getErrCode().equals("1")){
%>
		alert('<%=CAFMgr.getErrMsg()%>');
		<%if(request.getParameter("fp")!=null && request.getParameter("fp").equalsIgnoreCase("int_farmacia")){%>
		parent.window.frames['itemFrameMarb'].location='../pos/print_marbete.jsp?idDoc=<%=request.getParameter("doc_id")%>&qtyToPrint=1';
		<%} else if(request.getParameter("fp")!=null && request.getParameter("fp").equalsIgnoreCase("FAR")){%>
		window.location = '../pos/print_marbete.jsp?fp=FAR&idDoc=<%=request.getParameter("doc_id")%>&qtyToPrint=1';
		<%} else {%>
		parent.hidePopWin(false);
		<%if(request.getParameter("fp")!=null && request.getParameter("fp").equalsIgnoreCase("FAR")){%>
		parent.location = '../pos/list_marbete.jsp?fp=FAR';
		<%} else {%>
		parent.location = '../pos/list_marbete.jsp';
		<%}%>

		<%}%>
<%
} else throw new Exception(CAFMgr.getErrMsg());
}
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//post
%>
