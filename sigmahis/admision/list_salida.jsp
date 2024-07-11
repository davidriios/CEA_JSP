<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
AdmMgr.setConnection(ConMgr);

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

if(request.getParameter("centro_servicio")!=null&&!request.getParameter("centro_servicio").trim().equals("")) centro_servicio = request.getParameter("centro_servicio");
else{
al = SQLMgr.getDataList(sbSql.toString());
for(int i=0;i<al.size();i++){
	CommonDataObject cd = (CommonDataObject) al.get(i);
	centro_servicio = cd.getColValue("codigo");
	break;
}al.clear();
//throw new Exception("Estimado usuario, Usted no tiene centros de servicio asignado. Consulte con su Supervisor o el administrador del sistema!!!");
}
if(fg==null) fg = "salida";
if(fg.equals("AFA")){
	fgFilter = "";
} else if(fg.equals("")){
	fgFilter = "";
} else if(fg.equals("")){
	fgFilter = "";
} else if(fg.equals("")){
	fgFilter = "";
} else if(fg.equals("")){
	fgFilter = "";
}
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
	String secuencia ="",codigo="",fecha_nac="",nombre="";
	if (request.getParameter("secuencia") != null && !request.getParameter("secuencia").trim().equals("")){
		appendFilter += " and upper(c.secuencia) like '%"+request.getParameter("secuencia").toUpperCase()+"%'";
			secuencia = request.getParameter("secuencia");
	}
	if (request.getParameter("codigo") != null&& !request.getParameter("codigo").trim().equals("")){
		appendFilter += " and upper(b.pac_id) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
			codigo = request.getParameter("codigo");
	}
	if (request.getParameter("fecha_nacimiento") != null && !request.getParameter("fecha_nacimiento").trim().equals("")){
		appendFilter += " and trunc(b.f_nac) = to_date('"+request.getParameter("fecha_nacimiento")+"','dd/mm/yyyy')";
			fecha_nac = request.getParameter("fecha_nacimiento");
	}
	if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals("")){
		appendFilter += " and upper(b.nombre_paciente) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
			nombre = request.getParameter("nombre");
	}

	if (centro_servicio != null && !centro_servicio.trim().equals("")&& request.getParameter("nombre")!=null){
	sql = "select to_char(c.fecha_egreso, 'dd/mm/yyyy') fecha_egreso, to_char(c.fecha_ingreso, 'dd/mm/yyyy') fecha_ingreso, b.codigo, b.nombre_paciente as nombre, c.secuencia, c.pac_id, to_char(c.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, c.codigo_paciente, d.cama, d.codigo cod_cama, d.habitacion, nvl(e.empresa,' ') empresa, nvl(e.nombre_empresa, ' ') nombre_empresa, nvl(b.pasaporte, ' ') pasaporte, c.categoria, c.estado, /* nvl((select nvl(enviado,'N') from  tbl_sal_cama_auditoria  where compania = "+ (String) session.getAttribute("_companyId") +" and pac_id=c.pac_id and adm_secuencia = c.secuencia and centro_servicio  = "+centro_servicio+" ),'N')enviado */ decode((select count(*) from tbl_sal_cama_auditoria  where compania = "+ (String) session.getAttribute("_companyId") +" and pac_id=c.pac_id and adm_secuencia = c.secuencia and centro_servicio = "+centro_servicio+" and envio = 'S'), 0, 'N','S')enviado,to_char(b.f_nac,'dd/mm/yyyy') as f_nac from vw_adm_paciente b, tbl_adm_admision c, tbl_adm_cama_admision d, (select distinct a.pac_id, a.admision, to_char(a.empresa) empresa, b.nombre nombre_empresa from tbl_adm_beneficios_x_admision a, tbl_adm_empresa b where a.empresa = b.codigo and a.prioridad = 1 and a.estado = 'A' order by a.pac_id, a.admision) e, tbl_sal_habitacion f where c.estado in ('A') and c.categoria in (1,4) /*c.categoria = 1*/ and b.pac_id = c.pac_id and c.compania = " + (String) session.getAttribute("_companyId") + fgFilter + appendFilter+" and c.secuencia = d.admision and c.pac_id = d.pac_id and d.fecha_final is null and d.hora_final is null and d.habitacion = f.codigo and f.unidad_admin = "+centro_servicio+" and c.pac_id = e.pac_id(+) and c.secuencia = e.admision(+) order by c.fecha_egreso desc";

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
document.title = 'Salida - '+document.title;
var ignoreSelectAnyWhere = true;
function setVal(i){
	//if(eval('document.registros.chkEnvSal'+i).checked==true) document.registros.regCheckedES.value = i;
	//else document.registros.regCheckedES.value = '';
	/*if(eval('document.registros.chkEnvSal'+i).checked==true)
	{
		document.registros.regCheckedES.value = (parseInt(eval('document.registros.regCheckedES').value)+1);
	}
	else document.registros.regCheckedES.value = (parseInt(eval('document.registros.regCheckedES').value)-1);*/
}
function setValEnvio(i){
	/*if(eval('document.registros.chkEnvSal'+i).checked==true)
	{
		 if(eval('document.registros.enviado'+i).value !='S')
		 {
			 if(eval('document.registros.regCheckedES').value =='')document.registros.regCheckedES.value = i;

		 }else{ CBMSG.warning('Aviso de salida para este paciente ya fue enviado');
		 }
	}
	else document.registros.regCheckedES.value = '';

	*/
	if(eval('document.registros.chkEnvSal'+i).checked==true)
	{
		if(eval('document.registros.enviado'+i).value !='S')
		{
			document.registros.regCheckedES.value = (parseInt(eval('document.registros.regCheckedES').value)+1);
		}//else CBMSG.warning('Aviso de salida para este paciente ya fue enviado');
		//else
	}else{
		if(eval('document.registros.enviado'+i).value =='S')
		{
			CBMSG.warning('Aviso de salida para este paciente ya fue enviado');
			eval('document.registros.chkEnvSal'+i).checked=true;
			//document.registros.regCheckedES.value = (parseInt(eval('document.registros.regCheckedES').value)-1);
		}else document.registros.regCheckedES.value = (parseInt(eval('document.registros.regCheckedES').value)-1);
		}
	//else document.registros.regCheckedES.value = (parseInt(eval('document.registros.regCheckedES').value)-1);
}
function setValSalida(i){
	if(eval('document.registros.chkSal'+i).checked==true)
	{
		document.registros.regChecked.value = (parseInt(eval('document.registros.regChecked').value)+1);
	}
	else document.registros.regChecked.value = (parseInt(eval('document.registros.regChecked').value)-1);
}

function setValO(i){
	if(eval('document.registros.chkProc'+i).checked==true) document.registros.regCheckedOthers.value = i;
	else document.registros.regCheckedOthers.value = '';
}

function doProced(proc){
	var i = '';
	var pac_id = '';
	var admision = '';
	var fg = '';
	var fPage = 'general_page';
	var categoria = '';
	var estado = '';
	/*if(proc==1 ) i = document.registros.regCheckedES.value;
	else*/ i = document.registros.regCheckedOthers.value;

	if(/*document.registros.regCheckedES.value == '' &&*/document.registros.regCheckedOthers.value == '' && proc != 7 && proc != 8&& proc != 9) CBMSG.warning('Seleccione al menos un paciente/Admisión!');
	else {
		if(i!=''){
			pac_id = eval('document.registros.pac_id'+i).value;
			admision = eval('document.registros.admision'+i).value;
			categoria = eval('document.registros.categoria'+i).value;
			estado = eval('document.registros.estado'+i).value;
		}
		if(proc==1){
			if(categoria != '1' && categoria != '4' && categoria != '5') CBMSG.warning('La Categoría es diferente a 1, 4 y 5');
			else if(estado != 'A') CBMSG.warning('El estado de la admision es no Activo');
			else if(document.registros.regCheckedES.value == '') CBMSG.warning('Seleccione al menos un paciente/Admisión!');
			else abrir_ventana3('../admision/reg_reasignar_cama.jsp?noAdmision='+admision+'&pacienteId='+pac_id+'&fg='+fg+'&fPage='+fPage);

		} else if(proc==2){
			abrir_ventana3('../admision/reg_ext_dias.jsp?admisionNo='+admision+'&pacienteId='+pac_id+'&fg=extension_dias&fp='+fPage);
		} else if(proc==3){
			if(document.registros.regCheckedOthers.value == '') CBMSG.warning('Seleccione paciente/Admisión!');
			else {
				if(categoria==1){
					if(estado == 'A' || estado == 'S' || estado == 'E'){
						abrir_ventana3('../inventario/reg_sol_mat_pacientes.jsp?tr=PAC_S&admision='+admision+'&pac_id='+pac_id+'&fg='+fg+'&fPage='+fPage);
					} else CBMSG.warning('El estado de la admision no está dentro de los permitidos para hacer una requisición.');
				} else CBMSG.warning('La categoría de la admision no está dentro de los permitidos para hacer una requisición.');
			}
		} else if(proc==4){
			//abrir_ventana3('..//.jsp?admision='+admision+'&pac_id='+pac_id+'&fg='+fg+'&fPage='+fPage);
		} else if(proc==5){
			if(document.registros.regCheckedOthers.value == '') CBMSG.warning('Seleccione paciente/Admisión!');
			else abrir_ventana3('../facturacion/reg_cargo_dev.jsp?noAdmision='+admision+'&pacienteId='+pac_id+'&fg=HON&fPage='+fPage);
		} else if(proc==6){
			if(document.registros.regCheckedOthers.value == '') CBMSG.warning('Seleccione paciente/Admisión!');
			else abrir_ventana3('../facturacion/reg_cargo_dev_new.jsp?noAdmision='+admision+'&pacienteId='+pac_id+'&fg=PAC&fPage='+fPage);
		} else if(proc==7){
			abrir_ventana3('../admision/control_cama.jsp?admision='+admision+'&pac_id='+pac_id+'&fg='+fg+'&fPage='+fPage+'&cds=<%=centro_servicio%>');
		} else if(proc==8){
			document.registros.baction.value = "salida";
			if(parseInt(eval('document.registros.regChecked').value)<=0) CBMSG.warning('Seleccione al menos un paciente/Admisión!');
			else document.registros.submit();
		} else if(proc==9){
			document.registros.baction.value = "envio";
			if(parseInt(eval('document.registros.regCheckedES').value)<=0) CBMSG.warning('Seleccione al menos un paciente/Admisión!');
			else document.registros.submit();
		} else if(proc==10){
			var countCamas =  parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_cama_admision','fecha_final is null and admision = ' + admision + ' and pac_id = '+pac_id,''));
			if(countCamas==1){
				CBMSG.warning('No puede eliminar camas en donde el paciente solo tenga asignada una (1)');
			} else {
				var cama = eval('document.registros.cama'+i).value;
				var codigo = eval('document.registros.codigo'+i).value;
				var habitacion = eval('document.registros.habitacion'+i).value;
				var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';

				showPopWin('../common/run_process.jsp?fp=list_salida&actType=7&docType=CAMA&docId='+codigo+'&docNo='+cama+'&noAdmision='+admision+'&pacId='+pac_id+'&habitacion='+habitacion+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');

				/*if(executeDB('<%=request.getContextPath()%>','call sp_adm_anula_cama(' + admision + ', ' + pac_id + ', ' + codigo + ', \'' + cama + '\', \'' + habitacion + '\', <%=(String) session.getAttribute("_companyId")%>)')){
					var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
					CBMSG.warning(msg);
					window.location.reload(true);
				} else {
					var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
					CBMSG.warning(msg);
				}
				*/
			}
		}
	}
}

function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 1:msg='Reasignar Cama';break;
		case 2:msg='Extensión de Días';break;
		case 3:msg='Materiales y Medicamentos';break;
		case 4:msg='Devolución de Materiales y Medicamentos';break;
		case 5:msg='Honorarios Médicos';break;
		case 6:msg='Cargos / Devoluciones de Materiales';break;
		case 7:msg='Control de Camas';break;
		case 8:msg='Salida de Pacientes';break;
		case 9:msg='Aviso de Salida de Pacientes';break;
		case 10:msg='Anular cama';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}

function mouseOut(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	setoutc(obj,'ImageBorder');
	optDescObj.innerHTML='&nbsp;';
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="SALA - SALIDA DE PACIENTE"></jsp:param>
</jsp:include>


<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td align="right">
			<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
			<authtype type='50'><a href="javascript:doProced(1);"class="hint hint--top" data-hint="Reasignar Cama"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/reasignar_cama.png"></a></authtype>
			<!--<a href="javascript:doProced(2);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/scheduled-tasks.jpg"></a>-->
			<authtype type='51'><a href="javascript:doProced(3);"class="hint hint--top" data-hint="Materiales y Medicamentos"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/requisicion_de_materiales_para_pacientes.png"></a></authtype>
			<!--<a href="javascript:doProced(4);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/pills-3.jpg"></a>-->
			<authtype type='52'><a href="javascript:doProced(5);"class="hint hint--top" data-hint="Honorarios Médicos"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/honorario_medico.png"></a></authtype>
			<authtype type='53'><a href="javascript:doProced(6);"class="hint hint--top" data-hint="Cargos / Devoluciones de Materiales"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/cargos_devoluciones_de_materiales.png"></a></authtype>
			<authtype type='54'><a href="javascript:doProced(7);"class="hint hint--top" data-hint="Control de Camas"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/control_de_camas.png"></a></authtype>
			<authtype type='55'><a href="javascript:doProced(8);"class="hint hint--top" data-hint="Salida de Pacientes"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/salida_de_pacientes.png"></a></authtype>			
			<!--<authtype type='56'><a href="javascript:doProced(9);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,9)" onMouseOut="javascript:mouseOut(this,9)" src="../images/mailbox.jpg"></a></authtype>-->			
			<authtype type='57'><a href="javascript:doProced(10);"class="hint hint--top" data-hint="Anular cama"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/anular_admision.png"></a></authtype>
		</td>
	</tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="0">
				<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp",FormBean.GET);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
			<tr class="TextFilter">
				<td colspan="4">Sala:&nbsp;<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"centro_servicio",centro_servicio,false,false,0, "text10", "", "")%>
				No. Admisi&oacute;n<%=fb.intBox("secuencia","",false,false,false,10)%>
				Id. Paciente<%=fb.intBox("codigo","",false,false,false,10)%>
				&nbsp;Fecha Nac.<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="nameOfTBox1" value="fecha_nacimiento"/>
						<jsp:param name="valueOfTBox1" value=""/>
						<jsp:param name="clearOption" value="true"/>
					</jsp:include>&nbsp;Nombre<%=fb.textBox("nombre","",false,false,false,30)%><%=fb.submit("go","Ir")%></td>
			</tr>
			<%fb.appendJsValidation("if(document.search00.fecha_nacimiento.value!='' && !isValidateDate(document.search00.fecha_nacimiento.value)){CBMSG.warning('Formato de fecha inválida!');error++;}");%>
			<%=fb.formEnd(true)%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
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
				<%=fb.hidden("secuencia",""+secuencia)%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("fecha_nac",""+fecha_nac)%>
				<%=fb.hidden("nombre",""+nombre)%>
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
				<%=fb.hidden("secuencia",""+secuencia)%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("fecha_nac",""+fecha_nac)%>
				<%=fb.hidden("nombre",""+nombre)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<%fb = new FormBean("registros",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
<%=fb.hidden("regCheckedES","0")%>
<%=fb.hidden("regCheckedOthers","")%>
<%=fb.hidden("regChecked","0")%>
<%=fb.hidden("centro_servicio",centro_servicio)%>
<%=fb.hidden("baction","")%>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%">Habitaci&oacute;n</td>
			<td width="10%">Cama</td>
			<td width="27%">Nombre del Paciente</td>
			<td width="10%">Fecha Ingreso</td>
			<td width="10%">Fecha Nac.</td>
			<td width="5%">Id. Pte.</td>
			<td width="5%">No. Adm.</td>
			<td width="5%">Fallecido</td>
			<td width="5%"><!--Env&iacute;o--></td>
			<td width="5%">Salida</td>
			<td width="5%">&nbsp;</td>
			<!--<td width="3%">&nbsp;</td>-->
		</tr>
 <!--Inserte Grilla Aqui -->
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String statusDisplay = "",nIcon= "../images/blank.gif";;
	if (cdo.getColValue("estado").equalsIgnoreCase("A") && !cdo.getColValue("enviado").equalsIgnoreCase("S")) statusDisplay ="<img src=\"../images/lampara_rojo.png\">";
	if (cdo.getColValue("enviado").equalsIgnoreCase("S")){ statusDisplay = "<img src=\"../images/lampara_amarillo.png\">";/* nIcon = "../images/flag_red.gif";*/ }
%>
		<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
		<%=fb.hidden("admision"+i,cdo.getColValue("secuencia"))%>
		<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
		<%=fb.hidden("cama"+i,cdo.getColValue("cama"))%>
		<%=fb.hidden("habitacion"+i,cdo.getColValue("habitacion"))%>
		<%=fb.hidden("cod_paciente"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("pasaporte"+i,cdo.getColValue("pasaporte"))%>
		<%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>
		<%=fb.hidden("nombre_empresa"+i,cdo.getColValue("nombre_empresa"))%>
		<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("enviado"+i,cdo.getColValue("enviado"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("cod_cama"))%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("habitacion")%></td>
			<td align="center"><%=cdo.getColValue("cama")%></td>
			<td align="left">&nbsp;<%=cdo.getColValue("nombre")%></td>
			<td align="center"><%=cdo.getColValue("fecha_ingreso")%></td>
			<td align="center"><%=cdo.getColValue("f_nac")%></td>
			<td align="center"><%=cdo.getColValue("pac_id")%></td>
			<td align="center"><%=cdo.getColValue("secuencia")%></td>
			<td align="center"><%=fb.checkbox("chkFall"+i,""+i,false, false, "", "", "onClick=\"javascript:setVal("+i+")\"")%></td>
			<td align="center"><%//=fb.checkbox("chkEnvSal"+i,""+i,(cdo.getColValue("enviado") !=null &&cdo.getColValue("enviado").trim().equals("S")), false, "", "", "onClick=\"javascript:setValEnvio("+i+")\"")%><img src="<%=nIcon%>" height="20" width="20"></td>
			<td align="center"><%=fb.checkbox("chkSal"+i,""+i,false, false, "", "", "onClick=\"javascript:setValSalida("+i+")\"")%><%=statusDisplay%></td>
			<td align="center"><%=fb.checkbox("chkProc"+i,""+i,false, false, "", "", "onClick=\"javascript:setValO("+i+")\"")%></td>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
		</table>
	<%=fb.formEnd()%>
</div>
</div>
	</td>
</tr>
<tr class="TextRow01">
	<td align="center" class="TableLeftBorder TableRightBorder">
	<%fb = new FormBean("registrosxx",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart()%>
	<%=fb.hidden("regCheckedES","0")%>
	<%=fb.hidden("regCheckedOthers","")%>
	<%=fb.hidden("regChecked","0")%>
	<%=fb.hidden("centro_servicio",centro_servicio)%>
	<%=fb.hidden("baction","")%>
	<%=fb.checkbox("chkSalxx","",true, false, "", "", "")%><img src="../images/lampara_rojo.png">Pacientes Hospitalizados
	<%=fb.checkbox("chkSalyyy","",true, false, "", "", "")%><img src="../images/lampara_amarillo.png">Enviados Por Correo
	<%=fb.formEnd()%>
	</td>
</tr>
<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
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
				<%=fb.hidden("secuencia",""+secuencia)%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("fecha_nac",""+fecha_nac)%>
				<%=fb.hidden("nombre",""+nombre)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("secuencia",""+secuencia)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("fecha_nac",""+fecha_nac)%>
					<%=fb.hidden("nombre",""+nombre)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%}

else
{
	//int lineNo = ReqDet.getReqDetails().size();
	String artDel = "", key = "",cds=request.getParameter("centro_servicio");
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
		ad.setFormName("SAL31000b");

		if(request.getParameter("pasaporte"+i)!=null && !request.getParameter("pasaporte"+i).equals("")) ad.setPasaporte(request.getParameter("pasaporte"+i));
		if(request.getParameter("empresa"+i)!=null && !request.getParameter("empresa"+i).equals("")) ad.setEmpresa(request.getParameter("empresa"+i));
		else if(request.getParameter("empresa"+i).equals("")) ad.setEmpresa("null");
		if(request.getParameter("nombre_empresa"+i)!=null && !request.getParameter("nombre_empresa"+i).equals("")) ad.setNombreEmpresa(request.getParameter("nombre_empresa"+i));
		if(request.getParameter("chkFall"+i)!=null) ad.setFallecido("S");

	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("envio") && request.getParameter("chkEnvSal"+i)!=null &&(request.getParameter("enviado"+i) != "S") ) ad.setEnviaEmail("S");
	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("salida") &&request.getParameter("chkSal"+i)!=null) ad.setSalida("S");


	//if(request.getParameter("chkEnvSal"+i)!=null) ad.setEnviaEmail("S");
		//if(request.getParameter("chkSal"+i)!=null) ad.setSalida("S");

		if(request.getParameter("chkFall"+i)!=null || request.getParameter("chkEnvSal"+i)!=null || request.getParameter("chkSal"+i)!=null){
			alAdm.add(ad);
		}
	}
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg+"&cds="+cds+"&baction="+request.getParameter("baction"));
	AdmMgr.salidaPaciente(alAdm);
	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (AdmMgr.getErrCode().equals("1")){
%>
	alert('<%=AdmMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()%>/admision/list_salida.jsp?centro_servicio=<%=cds%>';
<%
} else throw new Exception(AdmMgr.getErrMsg());
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
