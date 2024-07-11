<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="CtrCMgr" scope="page" class="issi.admision.ControlCamaMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CtrCMgr.setConnection(ConMgr);

int iconHeight = 48;
int iconWidth = 48;

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fgFilter = "";
String fg = request.getParameter("fg");
String centro_servicio = "";
StringBuffer sbSql= new StringBuffer();
sbSql.append("select codigo, codigo||' - '||descripcion from tbl_cds_centro_servicio where estado = 'A' and origen = 'S' and compania_unorg=");
sbSql.append(session.getAttribute("_companyId"));
if(!UserDet.getUserProfile().contains("0"))
{
	sbSql.append(" and codigo in (");
		if(session.getAttribute("_cds")!=null)
			sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
		else sbSql.append("-1");
	sbSql.append(")");
}
sbSql.append(" order by descripcion ");

if(request.getParameter("cds")!=null && !request.getParameter("cds").trim().equals("")) centro_servicio = request.getParameter("cds");
if(request.getParameter("centro_servicio")!=null&& !request.getParameter("centro_servicio").trim().equals("")) centro_servicio = request.getParameter("centro_servicio");
	if(centro_servicio.trim().equals(""))
	{
		al = SQLMgr.getDataList(sbSql.toString());
									
		for(int i=0;i<al.size();i++){
			CommonDataObject cd = (CommonDataObject) al.get(i);
			centro_servicio = cd.getColValue("codigo");
			break;
	}
	al.clear();
	//throw new Exception("Estimado usuario, Usted no tiene centros de servicio asignado. Consulte con su Supervisor o el administrador del sistema!!!");
}

if(fg==null) fg = "salida";
if(fg.equals("AFA"))fgFilter = "";
else if(fg.equals(""))fgFilter = "";
else if(fg.equals(""))fgFilter = "";
else if(fg.equals(""))fgFilter = "";
else if(fg.equals(""))fgFilter = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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
	String secuencia="",codigo="",nombre="";
	if (request.getParameter("secuencia") != null && !request.getParameter("secuencia").trim().equals("")){
		appendFilter += " and upper(a.adm_secuencia) like '%"+request.getParameter("secuencia").toUpperCase()+"%'";

		secuencia = request.getParameter("secuencia");
	} 
	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals("")){
		appendFilter += " and upper(b.pac_id) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		codigo = request.getParameter("codigo");
	} 
	if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals("")){
		appendFilter += " and (upper(b.nombre_paciente) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		nombre = request.getParameter("nombre");
	}	
	
	if (centro_servicio != null && !centro_servicio.trim().equals("")){
	sql = "select a.habitacion, a.cama, b.nombre_paciente  as nombre, to_char(b.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, b.codigo codigo_paciente, a.adm_secuencia admision, to_char(a.fecha_salida,'dd/mm/yyyy hh12:mi am') fecha_salida, a.estado_cama, nvl(to_char(a.hora_inicio_limpieza,'hh:mi am'), ' ') hora_inicio_limpieza, nvl(to_char(a.hora_final_limpieza,'hh:mi am'), ' ') hora_final_limpieza, nvl(a.reubicacion, ' ') reubicacion, b.pac_id,to_char(b.f_nac,'dd/mm/yyyy') as f_nac from tbl_sal_cama_auditoria a, vw_adm_paciente b where a.pac_id = b.pac_id /* and a.salida = 'S' and a.disponible = 'N' */ and a.estado_cama in('T','M') and a.centro_servicio = "+centro_servicio + " and a.compania = " + (String) session.getAttribute("_companyId") + appendFilter;  

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

}//else throw new Exception("Estimado usuario, Usted no tiene centros de servicio asignado. Consulte con su Supervisor o el administrador del sistema!!!");


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
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Bed Control - '+document.title;
function setBAction(fName,actionValue){document.registros.baction.value = actionValue;doSubmit();}
function doSubmit(){if(chkAllHIL()) document.registros.submit();}
function setMandValues(form){form.centro_servicio.value = document.search00.centro_servicio.value;form.submit();}
function reg_motivo_demora(i){var pac_id = eval('document.registros.pac_id'+i).value;var cod_paciente = eval('document.registros.cod_paciente'+i).value;var fecha_nac = eval('document.registros.fecha_nacimiento'+i).value;var admision = eval('document.registros.admision'+i).value;var cama = eval('document.registros.cama'+i).value;var habitacion = eval('document.registros.habitacion'+i).value;var centro_servicio = '<%=centro_servicio%>';abrir_ventana('../admision/reg_mot_demora.jsp?mode=add&cama='+cama+'&habitacion='+habitacion+'&pacienteId='+pac_id+'&cod_paciente='+cod_paciente+'&fecha_nacimiento='+fecha_nac+'&noAdmision='+admision+'&centro_servicio='+centro_servicio);}
function reg_notas(i){var pac_id = eval('document.registros.pac_id'+i).value;var cod_paciente = eval('document.registros.cod_paciente'+i).value;var fecha_nac = eval('document.registros.fecha_nacimiento'+i).value;var admision = eval('document.registros.admision'+i).value;var cama = eval('document.registros.cama'+i).value;var habitacion = eval('document.registros.habitacion'+i).value;var centro_servicio = '<%=centro_servicio%>';abrir_ventana('../admision/reg_nota_extra.jsp?mode=add&cama='+cama+'&habitacion='+habitacion+'&pacienteId='+pac_id+'&cod_paciente='+cod_paciente+'&fecha_nacimiento='+fecha_nac+'&noAdmision='+admision+'&centro_servicio='+centro_servicio);}
function chkHIL(i){var cama = eval('document.registros.chkDisp'+i);var hil = eval('document.registros.hil'+i).value;var x = 0;if(cama.checked==true && hil == ''){CBMSG.warning('Introduzca Hora de Inicio de limpieza!');cama.checked = false;x++;}if(x==0) return true;else return false;}
function chkAllHIL(){var size = document.registros.keySize.value;var count = 0, countCHK = 0;var cama = '', habitacion = '';for(i=0;i<size;i++){hil = eval('document.registros.hil'+i).value;var estado = eval('document.registros.estado'+i).value;var estadoOld = eval('document.registros.estadoOld'+i).value; if(hil == '' && (estado==estadoOld)){countCHK++;}}if((countCHK)!=size) return true;else {CBMSG.warning('Introduzca al menos una Hora de Inicio de Limpieza!');return false;}}
function chkDisp(i){var chkMant= eval('document.registros.estado'+i).value; var disp = eval('document.registros.chkDisp'+i);if(disp.checked==true){CBMSG.warning('La Cama está configurada para ponerla disponible.. Verifique!');eval('document.registros.estado'+i).value=eval('document.registros.estadoOld'+i).value; return false;}}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="SALA - BED CONTROL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="">
				<td colspan="4" class="RedTextBold">EN ESTA PANTALLA SE LLEVA EL CONTROL DE LIMPIEZA DE LAS CAMAS UNA VEZ QUE AL PACIENTE SE LE HAYA DADO SALIDA O REASIGNADO CAMA!</td>
			</tr>
			<tr class="">
				<td colspan="4" class=""></tr>
			<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<td width="25%">
				Sala:&nbsp;
				<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"centro_servicio",centro_servicio,false,false,0, "text10", "", "")%>
				</td>
				<td width="25%">
					No. Admisi&oacute;n
					<%=fb.intBox("secuencia","",false,false,false,10)%>
				</td>
				<td width="25%">
					Id. Paciente
					<%=fb.intBox("codigo","",false,false,false,10)%>
				</td>
				<td width="25%">
					Nombre
					<%=fb.intBox("nombre","",false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd(true)%>

			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("centro_servicio",centro_servicio)%>
				<%=fb.hidden("secuencia",secuencia)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("centro_servicio",centro_servicio)%>
				<%=fb.hidden("secuencia",secuencia)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<%fb = new FormBean("registros","","post","");%>
<%=fb.formStart()%>
<%=fb.hidden("regCheckedES","")%>
<%=fb.hidden("regCheckedOthers","")%>
<%=fb.hidden("centro_servicio",centro_servicio)%>
<%=fb.hidden("baction","")%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<div style=" OVERFLOW: auto; WIDTH: 100%; TOP: 48px; HEIGHT: 232px">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td>Habit.</td>
			<td>Cama</td>
			<td>Nombre del Paciente</td>
			<td>Fecha Nac.</td>
			<td>Id. Pte.</td>
			<td>No. Adm.</td>
			<td>Fecha Salida</td>
			<td>Hora Ini. Limp.</td>
			<td>Hora Fin Limp.</td>
			<td>Est.</td>
			<td>Estado</td>
			<td>Disp.</td>
			<td colspan="2">Mot. Demora / Nota X.</td>
		</tr>
 <!--Inserte Grilla Aqui -->
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
		<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
		<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
		<%=fb.hidden("cama"+i,cdo.getColValue("cama"))%>
		<%=fb.hidden("habitacion"+i,cdo.getColValue("habitacion"))%>
		<%=fb.hidden("cod_paciente"+i,cdo.getColValue("codigo_paciente"))%>
		<%=fb.hidden("pasaporte"+i,cdo.getColValue("pasaporte"))%>
		<%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>
		<%=fb.hidden("nombre_empresa"+i,cdo.getColValue("nombre_empresa"))%>
		<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
		<%=fb.hidden("estadoOld"+i,cdo.getColValue("estado_cama"))%> 
		
		<%
		String imagEstado = "";
		String estado = cdo.getColValue("estado_cama");
		String hora_i_limpieza = cdo.getColValue("hora_inicio_limpieza");
		String hora_f_limpieza = cdo.getColValue("hora_final_limpieza");
		String reubicacion = cdo.getColValue("reubicacion");
		String hil="hil"+i;
		String hfl="hfl"+i;
		if(estado.equals("T") && hora_i_limpieza.equals("") && hora_f_limpieza.equals("") && reubicacion.equals("")){
			imagEstado = "../images/lampara_roja.gif";
		} else if(estado.equals("T") && hora_i_limpieza.equals("") && hora_f_limpieza.equals("") && reubicacion.equals("S")){
			imagEstado = "../images/lampara_amarilla.gif";
		} else if(estado.equals("T") && !hora_i_limpieza.equals("") && hora_f_limpieza.equals("")){
			imagEstado = "../images/lampara_verde.gif";
		} else if(estado.equals("T") && !hora_i_limpieza.equals("") && !hora_f_limpieza.equals("")){
			imagEstado = "../images/lampara_blanca.gif";
		}
		 else if(estado.equals("M") ){
			imagEstado = "../images/lampara_gris.png";
		}

		%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("habitacion")%></td>
			<td align="center"><%=cdo.getColValue("cama")%></td>
			<td align="left">&nbsp;<%=cdo.getColValue("nombre")%></td>
			<td align="center"><%=cdo.getColValue("f_nac")%></td>
			<td align="center"><%=cdo.getColValue("pac_id")%></td>
			<td align="center"><%=cdo.getColValue("admision")%></td>
			<td align="center"><%=cdo.getColValue("fecha_salida")%></td>
			<td align="center">
				<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="<%=hil%>" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_inicio_limpieza")%>" />
					<jsp:param name="fieldClass" value="Text10" />
					<jsp:param name="buttonClass" value="Text10" />
					<jsp:param name="format" value="hh12:mi am" />
				</jsp:include>
			</td>
			<td align="center">
				<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="<%=hfl%>" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_final_limpieza")%>" />
					<jsp:param name="fieldClass" value="Text10" />
					<jsp:param name="buttonClass" value="Text10" />
					<jsp:param name="format" value="hh12:mi am" />
				</jsp:include>
			</td>
			<td align="center"><img src="<%=imagEstado%>">
			<td align="center"><%=fb.select("estado"+i,"T=TRAMITE,M=MANTENIMIENTO",cdo.getColValue("estado_cama"),false,false,0,"Text10","","onChange=\"javascript:chkDisp("+i+")\"")%></td>
			<td align="center"><%=fb.checkbox("chkDisp"+i,""+i,false, false, "", "", "onClick=\"javascript:chkHIL("+i+")\"")%></td>
			
			<td align="center"><a href="javascript:reg_motivo_demora(<%=i%>)" class="Link00">Motivo</a></td>
			<td align="center"><a href="javascript:reg_notas(<%=i%>)" class="Link00">Notas</a></td>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
		</table>
</div>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="center" class="TableLeftBorder TableRightBorder TableTopBorder">
		<img src="../images/lampara_roja.gif">Cama en Tr&aacute;mite&nbsp;&nbsp;&nbsp;
		<img src="../images/lampara_verde.gif">Cama en Limpieza&nbsp;&nbsp;&nbsp;
		<img src="../images/lampara_blanca.gif">T&eacute;rmino de Limpieza&nbsp;&nbsp;&nbsp;
		<img src="../images/lampara_amarilla.gif">Cama en Tr&aacute;mite por Reubicaci&oacute;n
		<img src="../images/lampara_gris.png">Cama en Mantenimiento
				&nbsp;
				&nbsp;
				&nbsp;
				<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
	</td>
</tr>
</table>
<%=fb.formEnd()%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("centro_servicio",centro_servicio)%>
				<%=fb.hidden("secuencia",secuencia)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("centro_servicio",centro_servicio)%>
				<%=fb.hidden("secuencia",secuencia)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	System.out.println("=====================POST=====================");
	//int lineNo = ReqDet.getReqDetails().size();
	String artDel = "", key = "";;
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	ArrayList alAdm = new ArrayList();
	for(int i=0;i<keySize;i++){
		Admision ad = new Admision();
		ad.setPacId(request.getParameter("pac_id"+i));
		ad.setNoAdmision(request.getParameter("admision"+i));
		ad.setFechaNacimiento(request.getParameter("fecha_nacimiento"+i));
		ad.setNombrePaciente(request.getParameter("nombre"+i));
		ad.setCama(request.getParameter("cama"+i));
		ad.setHabitacion(request.getParameter("habitacion"+i));
		ad.setCodigoPaciente(request.getParameter("cod_paciente"+i));
		ad.setCentroServicio(request.getParameter("centro_servicio"));
		ad.setUsuarioCreacion((String) session.getAttribute("_userName"));
		ad.setCompania((String) session.getAttribute("_companyId"));
		ad.setFormName("SAL310007_BED");
		if((request.getParameter("estado"+i)!=request.getParameter("estadoOld"+i)))
		ad.setEstadoCama(request.getParameter("estado"+i));
		
		if(request.getParameter("chkDisp"+i)!=null){ ad.setLimpieza("S");ad.setEstadoCama("");}
		else ad.setLimpieza("N");

		if(request.getParameter("hfl"+i)!=null && !request.getParameter("hfl"+i).equals("")) ad.setHoraFinLimpieza(request.getParameter("hfl"+i));

		if((request.getParameter("hil"+i)!=null && !request.getParameter("hil"+i).equals("")) || (request.getParameter("estado"+i)!=request.getParameter("estadoOld"+i))  ){
			if(request.getParameter("hil"+i)!=null && !request.getParameter("hil"+i).equals(""))ad.setHoraInicioLimpieza(request.getParameter("hil"+i));
			alAdm.add(ad);
		}
		
		
	}
	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		CtrCMgr.add(alAdm);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (CtrCMgr.getErrCode().equals("1")){
%>
	alert('<%=CtrCMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()%>/admision/control_cama.jsp?centro_servicio=<%=request.getParameter("centro_servicio")%>';
<%
} else throw new Exception(CtrCMgr.getErrMsg());
%>
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
