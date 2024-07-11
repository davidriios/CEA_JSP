<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="NotMgr" scope="page" class="issi.planmedico.NotaMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htNot" scope="session" class="java.util.Hashtable"/>
<%
/* Check whether the user is logged in or not what access rights he has----------------------------
0         ACCESO TODO SISTEMA
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	SQLMgr.setConnection(ConMgr);
	CmnMgr.setConnection(ConMgr);
	NotMgr.setConnection(ConMgr);

	UserDet = SecMgr.getUserDetails(session.getId());
	session.setAttribute("UserDet",UserDet);
	issi.admin.ISSILogger.setSession(session);

	String creatorId = UserDet.getUserEmpId();

	String mode=request.getParameter("mode");
	boolean viewMode = false;
	String change=request.getParameter("change");
	String type=request.getParameter("type");
	String compId=(String) session.getAttribute("_companyId");
	String tipo = request.getParameter("tipo");
	String pac_id = request.getParameter("pac_id");
	String id = request.getParameter("id");
	String fg = request.getParameter("fg");
	String tab = request.getParameter("tab");
	String title = "";
	String key = "";
	ArrayList al = new ArrayList();
	StringBuffer sbSql = new StringBuffer();

	if(mode==null) mode="add";
	if(mode.equals("view")) viewMode=true;
	if(fg==null) fg="";
	if (type == null) type = "0";
	if(id==null) id="";

	if(request.getMethod().equalsIgnoreCase("GET")){
		if (change==null){
			htNot.clear();
			sbSql.append("select pac_id, id, num_tarjeta_cta, to_char(fecha_inicio, 'dd/mm/yyyy') fecha_inicio, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_modificacion, estado, observacion, tipo, decode(a.estado, 'A', 'Activo', 'I', 'Inactivo', 'R', 'Reemplazado', a.estado) estado_desc, decode(tipo, 'C', 'ACH', 'T', 'Tarjeta', 'V', 'Voluntario', tipo) tipo_desc, (select nombre_banco from tbl_adm_ruta_transito b where b.ruta = a.cod_banco) banco_desc, (select descripcion from tbl_cja_tipo_tarjeta t where t.codigo = a.tipo_tarjeta) tipo_tarjeta_desc, periodo, to_char(fecha_vence, 'dd/mm/yyyy') fecha_vence  from tbl_adm_cta_tarjeta a where a.pac_id = ");
			sbSql.append(pac_id);
			sbSql.append(" order by fecha_creacion desc");

			if (pac_id == null) throw new Exception("El Parametro no es válido. Por favor intente nuevamente!");
			al = SQLMgr.getDataList(sbSql.toString());
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				if ((i+1) < 10) key = "00"+(i+1);
				else if ((i+1) < 100) key = "0"+(i+1);
				else key = ""+(i+1);

				try {
					htNot.put(key, cdoDet);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
	document.formTarjeta.tab.value = parent.document.form4.tab.value;
	//console.log('reg_tarjeta_cta_det');
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	window.frames['iFrameNotas'].doAction();
}

function doSubmit(valor){
	document.formTarjeta.submit();
}

function ver(pac_id, id, mode){
	var iFrameName = '', page = '';
	iFrameName='iFrameNotas';
	page = '../admision/reg_tarjeta_cta_det.jsp?pac_id=<%=pac_id%>&id='+id+'&mode='+mode;
	//alert(page);
	window.frames[iFrameName].location=page;
}

</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<%fb = new FormBean("formTarjeta",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tab",tab)%>
	<table align="center" width="100%" cellpadding="0" cellspacing="0">
    <tr>
			<td class="TableBorder">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
					<tr class="" align="center">
						<td colspan="4">
						<div id="list_opMain" width="100%" style="overflow:scroll;position:relative;height:240">
						<!--<div id="list_op" width="100%" style="overflow;position:absolute">-->
							<table width="99%" border="0" align="center">
								<tr class="TextHeader">
									<td width="10%">Fecha Inicio</td>
									<td width="15%">Usuario</td>
									<td width="13%">No. Documento</td>
									<td width="10%">Tipo Documento</td>
									<td width="20%">Banco</td>
									<!--<td width="10%">Periodo</td>-->
									<td width="10%">Fecha Creaci&oacute;n</td>
									<td width="10%">Estado</td>
									<td align="center" width="4%">&nbsp;</td>
									<td align="center" width="6%"><%=fb.button("addClte","Agregar",false,viewMode,"text10","","onClick=\"javascript:ver("+pac_id+", 0, 'add');\"")%></td>
								</tr>
								<%
								key = "";
								if (htNot.size() != 0) al = CmnMgr.reverseRecords(htNot);
								for (int i=0; i<htNot.size(); i++){
									key = al.get(i).toString();
									CommonDataObject cdo = (CommonDataObject) htNot.get(key);
									String color = "";
									if (i%2 == 0) color = "TextRow02";
									else color = "TextRow01";
									//CmnMgr.getDecryptToShow()
								%>
								<%=fb.hidden("id"+i, cdo.getColValue("id"))%>
								<%=fb.hidden("pac_id"+i, cdo.getColValue("pac_id"))%>
								<tr class="<%=color%>" align="center">
									<td><%=cdo.getColValue("fecha_inicio")%></td>
									<td><%=cdo.getColValue("usuario_creacion")%></td>
									<td align="left"><%=(!cdo.getColValue("num_tarjeta_cta").equals("")?cdo.getColValue("num_tarjeta_cta"):"")%></td>
									<td><%=cdo.getColValue("tipo_desc")%></td>
									<td><%=cdo.getColValue("banco_desc")%></td>
									<!--<td><%=cdo.getColValue("periodo")%></td>-->
									<td><%=cdo.getColValue("fecha_creacion")%></td>
									<td><%=cdo.getColValue("estado_desc")%></td>
									<td align="center"><authtype type='1'><a href="javascript:ver(<%=cdo.getColValue("pac_id")%>, <%=cdo.getColValue("id")%>, 'view')" class="Link02Bold">Ver</a></authtype></td>
									<td align="center"><authtype type='4'><%if((mode.equals("edit") || (mode.equals("add") && cdo.getColValue("usuario_creacion").equals((String) session.getAttribute("_userId")))) && !cdo.getColValue("estado").equals("I") && !cdo.getColValue("estado").equals("R")){%><a href="javascript:ver(<%=cdo.getColValue("pac_id")%>, <%=cdo.getColValue("id")%>, 'edit')" class="Link02Bold">Editar</a><%}%></authtype></td>
								</tr>
								<%}%>
							</table>
						</div>
						</div>
						</td>
					</tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameNotas" id="iFrameNotas" frameborder="0" align="center" width="100%" height="280" scrolling="yes" src="../admision/reg_tarjeta_cta_det.jsp?mode=<%=mode%>&pac_id=<%=pac_id%>&id=<%=id%>"></iframe>
						</td>
					</tr>			
				</table>
			</td>
		</tr>
	</table>
<%=fb.hidden("size", ""+htNot.size())%>	
<%=fb.formEnd(true)%>
<%
%>
</body>
</html>
<%
}//post
%>
