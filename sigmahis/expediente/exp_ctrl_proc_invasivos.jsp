<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.ControlInvasivo"%>
<%@ page import="issi.expediente.DetalleControl"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="CPIMgr" scope="session" class="issi.expediente.ControlInvasivoMgr" />
<jsp:useBean id="iControl" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CPIMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ControlInvasivo control = new ControlInvasivo();

boolean viewMode = false;
int rowCount = 0;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");

if (desc == null) desc = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (mode.equals("")) mode = "A";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fecha_eval = request.getParameter("fecha_eval");
String filter1 = "";
String filter = "", op="", appendFilter = "";

String key = "";

if (request.getMethod().equalsIgnoreCase("GET")){

	 iControl.clear();
	 sql="select to_char(fecha_registro,'dd/mm/yyyy') as fecha from tbl_sal_infeccion_paciente where pac_id="+pacId+" and secuencia="+noAdmision+"  and (pac_id,secuencia,fecha_registro) in (select pac_id, secuencia, fecha_inf from TBL_SAL_DETALLE_INFECCION) order by fecha_creacion desc";
	 al2 = SQLMgr.getDataList(sql);
	 for (int i=1; i<=al2.size(); i++){
		cdo = (CommonDataObject) al2.get(i-1);
		cdo.setKey(iControl.size()+1);

		if(cdo.getColValue("fecha").equals(cDateTime.substring(0,10)))
		{
		cdo.addColValue("OBSERVACION","Evaluacion actual");
			op = "0";
		}else
		{cdo.addColValue("OBSERVACION","Evaluacion "+ (1+al2.size() - i));
				appendFilter = "1";
		}
		try
		{
			iControl.put(cdo.getKey(), cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	 }//for
	 
	if(al2.size() == 0){
		if (!viewMode) modeSec = "add";
		cdo = new CommonDataObject();
		cdo.addColValue("FECHA",cDateTime.substring(0,10));
		cdo.addColValue("OBSERVACION","Evaluacion Actual");
		
		cdo.setAction("I");
		cdo.setKey(iControl.size()+1);

		try
		{
			iControl.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}

if(fecha_eval != null){
filter = fecha_eval;
if(fecha_eval.equals(cDateTime.substring(0,10))){
modeSec="edit";
if(!viewMode)viewMode= false;}
}
else
filter = cDateTime.substring(0,10);


	sql="select to_char(fecha_registro,'dd/mm/yyyy') as fechaRegistro, usuario_creacion as usuarioCreacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, usuario_modificacion as usuarioModificacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fechaModificacion, to_char(fecha,'dd/mm/yyyy') as fecha from tbl_sal_infeccion_paciente where pac_id="+pacId+" and secuencia="+noAdmision+" and to_date(to_char(fecha_registro,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+filter+"','dd/mm/yyyy')";

	control = (ControlInvasivo) sbb.getSingleRowBean(ConMgr.getConnection(), sql, ControlInvasivo.class);
if(control == null)
{
			control = new ControlInvasivo();
			control.setFecha(cDateTime.substring(0,10));
			control.setFechaRegistro(cDateTime.substring(0,10));
			control.setUsuarioCreacion(UserDet.getUserName());
			control.setFechaCreacion(cDateTime);
			control.setUsuarioModificacion(UserDet.getUserName());
			control.setFechaModificacion(cDateTime);
			if (!viewMode) modeSec = "add";
}
else if (!viewMode) modeSec = "edit";

	sql="SELECT a.codigo as codigoInfeccion, a.descripcion as descripcion, b.codigo as codigo, b.infec_pac as infecPac, to_char(b.fecha_inf,'dd/mm/yyyy') as fechaInf, to_char(b.fecha_ini,'dd/mm/yyyy') as fechaIni, to_char(b.fecha_cambio,'dd/mm/yyyy') as fechaCambio, to_char(b.fecha_retiro,'dd/mm/yyyy') as fechaRetiro, b.observacion as observacion, to_char(b.fecha_cultivo,'dd/mm/yyyy') as fechaCultivo, b.total_dias as totalDias, decode(b.codigo, null, 'I', 'U') status FROM TBL_SAL_INFECCION a, TBL_SAL_DETALLE_INFECCION b where a.codigo=b.codigo(+) and b.pac_id(+)="+pacId+" and b.secuencia(+)="+noAdmision+" and to_date(to_char(b.fecha_inf(+),'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+filter+"','dd/mm/yyyy') "+(!viewMode?" and estado = 'A'":"")+" ORDER BY a.orden ASC ";
	al = SQLMgr.getDataList(sql);
	if (al.size() == 0 && control == null)
		if (!viewMode) modeSec = "add";
	else
			if (!viewMode) modeSec = "edit";

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'CONTROL DE PROCEDIMIENTOS INVASIVOS - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function verControl(k){var fecha_e = eval('document.form0.fecha_evaluacion'+k).value ;window.location = '../expediente/exp_ctrl_proc_invasivos.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval='+fecha_e;}
function doAction(){setHeight();checkViewMode();}
function setHeight(){newHeight();}
function imprimir(){var fecha = document.form0.fechaRegistro.value;abrir_ventana1('../expediente/print_control_invasivos.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fechaControl='+fecha);}
function addControl(){window.location = '../expediente/exp_ctrl_proc_invasivos.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>';}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr>
		<td>
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("modeSec",modeSec)%>
			<%=fb.hidden("seccion",seccion)%>
			<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("usuarioCreacion",control.getUsuarioCreacion())%>
			<%=fb.hidden("fechaCreacion",control.getFechaCreacion())%>
			<%=fb.hidden("usuarioModificacion",control.getUsuarioModificacion())%>
			<%=fb.hidden("fechaModificacion",control.getFechaModificacion())%>
			<%=fb.hidden("fecha",control.getFecha())%>
            <%=fb.hidden("desc",desc)%>
					<tr>
					<td  colspan="6" style="text-decoration:none; cursor:pointer">
					<div id="listado" width="100%" class="exp h100">
					<div id="detListado" width="98%" style="child">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td colspan="2">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="30%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
							<td width="70%"><cellbytelabel id="3">Observaci&oacute;n</cellbytelabel></td>
						</tr>
							<%if(appendFilter.equals("1") && !op.trim().equals("0")){%>
							<%=fb.hidden("fecha_evaluacion0",cDateTime.substring(0,10))%>
							<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')" style="cursor:pointer " onClick="javascript:verControl(0)" >
									<td><%=cDateTime.substring(0,10)%></td>
									<td><cellbytelabel id="4">Evaluaci&oacute;n actual</cellbytelabel></td>
							</tr>
<%}
al2 = CmnMgr.reverseRecords(iControl);
for (int i=1; i<=iControl.size(); i++)
{
	key = al2.get(i-1).toString();
	cdo = (CommonDataObject) iControl.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>

		<%=fb.hidden("fecha_evaluacion"+i,cdo.getColValue("fecha"))%>


		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " onClick="javascript:verControl(<%=i%>)" >
				<td><%=cdo.getColValue("fecha")%></td>
				<td><%=cdo.getColValue("observacion")%></td>

		</tr>
<%
}
%>
						</table>
						</div>
						</div>
					</td>
				</tr>
			<tr class="TextRow02">
				<td colspan="6">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4"><cellbytelabel id="2">Fecha</cellbytelabel>:
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fechaRegistro" />
				<jsp:param name="valueOfTBox1" value="<%=control.getFechaRegistro()%>" />
				<jsp:param name="readonly" value="<%=(viewMode||(!modeSec.trim().equals("add")))?"y":"n"%>"/>
				</jsp:include>
				</td>
				<td colspan="2" align="right"><a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="5">Imprimir</cellbytelabel> ]</a>
                <% if (!mode.equals("view") ){%>
                  <a href="javascript:addControl()" class="Link00">[ <cellbytelabel id="6">Agregar</cellbytelabel> ]</a>
                <%}%>
                </td>
				</tr>

			<tr class="TextHeader" align="center">
				<td width="25%"><cellbytelabel id="7">Procedimiento</cellbytelabel></td>
				<td width="15%"><cellbytelabel id="8">Fecha de Inicio</cellbytelabel> </td>
				<td width="15%"><cellbytelabel id="9">Fecha de cambio</cellbytelabel> </td>
				<td width="15%"><cellbytelabel id="10">Fecha de cultivo</cellbytelabel> </td>
				<td width="15%"><cellbytelabel id="11">Fecha de Retiro</cellbytelabel> </td>
				<td width="15%"><cellbytelabel id="12">Total de D&iacute;as</cellbytelabel> </td>
			</tr>
		<tr>
				<td colspan="6">
	<div id="listado2" width="100%" class="exp h400">
					<div id="detListado2" width="98%" class="child">
				<table width="100%" cellpadding="1" cellspacing="0">
<%
for (int i=1; i<=al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i-1);
	//if(cdo.getColValue("fechaIni") == null || cdo.getColValue("fechaIni").trim().equals(""))
	//cdo.addColValue("fechaIni",cDateTime.substring(0,10));
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow02";
%>
			<%=fb.hidden("key"+i,key)%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
			<%=fb.hidden("codigoInfeccion"+i,cdo.getColValue("codigoInfeccion"))%>
			<%=fb.hidden("fecha_infeccion"+i,control.getFechaRegistro())%>
			<%=fb.hidden("status"+i, cdo.getColValue("status"))%>

			<tr class="<%=color%>" align="center">
				<td align="left" width="25%"><%=cdo.getColValue("descripcion")%></td>
				<td width="15%">
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%="fechaIni"+i%>" />
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaIni")%>" />
						</jsp:include>

				</td>
				<td width="15%">
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%="fechaCambio"+i%>" />
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaCambio")%>" />
						</jsp:include>				</td>
				<td width="15%">
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%="fechaCultivo"+i%>" />
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaCultivo")%>" />
						</jsp:include>				</td>
				<td width="15%">
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%="fechaRetiro"+i%>" />
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaRetiro")%>" />
						</jsp:include>				</td>
				<td width="15%"><%=fb.textBox("totalDias"+i,cdo.getColValue("totalDias"),false,false,viewMode,5,"Text10",null,null)%></td>
			</tr>
			<tr class="<%=color%>" >
				<td valign="middle"align="right"><cellbytelabel id="3">Observaci&oacute;n</cellbytelabel>:</td>
				<td colspan="5"><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,60,2,2000,null,"width:100%","")%></td>
			</tr>
<%
}
%></table>
</div>
						</div>

							</td>
	</tr>

			<tr class="TextRow02" >
				<td colspan="6" align="right">
				<cellbytelabel id="14">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="15">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="16">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
</td>
			</tr>
			<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size= 0;
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));

		al.clear();
		ControlInvasivo controlInv = new ControlInvasivo();

		controlInv.setFecNacimiento(request.getParameter("dob"));
		controlInv.setCodPaciente(request.getParameter("codPac"));
		controlInv.setSecuencia(request.getParameter("noAdmision"));
		controlInv.setFecha(request.getParameter("fecha"));
		controlInv.setFechaRegistro(request.getParameter("fechaRegistro"));
		controlInv.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
		controlInv.setFechaCreacion(request.getParameter("fechaCreacion"));
		controlInv.setUsuarioModificacion(UserDet.getUserName());
		controlInv.setFechaModificacion(cDateTime);
		controlInv.setPacId(request.getParameter("pacId"));

		for (int i=1; i<=size; i++)
		{
				if(request.getParameter("fechaIni"+i) != null && !request.getParameter("fechaIni"+i).trim().equals(""))
				{
				DetalleControl detCon = new DetalleControl();

				detCon.setCodPaciente(request.getParameter("codPac"));
				detCon.setFecNacimiento(request.getParameter("dob"));
				detCon.setSecuencia(request.getParameter("noAdmision"));
				detCon.setCodigo(""+i);//?????????????????
				detCon.setInfecPac(request.getParameter("codigoInfeccion"+i));
				detCon.setFechaInf(request.getParameter("fechaRegistro")); // request.getParameter("fecha_infeccion"), tine que ser la misma fecha que
																	            // request.getParameter("fechaRegistro"), sino viola SDIP_SIP_FK
				detCon.setFechaIni(request.getParameter("fechaIni"+i));
				detCon.setFechaCambio(request.getParameter("fechaCambio"+i));
				detCon.setFechaRetiro(request.getParameter("fechaRetiro"+i));
				detCon.setObservacion(request.getParameter("observacion"+i));
				detCon.setFechaCultivo(request.getParameter("fechaCultivo"+i));
				detCon.setTotalDias(request.getParameter("totalDias"+i));
				detCon.setPacId(request.getParameter("pacId"));
                detCon.setStatus(request.getParameter("status"+i));

				al.add(detCon);
				controlInv.addDetalleControl(detCon);
				}
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
						ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add"))
				{
						CPIMgr.add(controlInv);
				}
				else if (modeSec.equalsIgnoreCase("edit"))
				{
						CPIMgr.update(controlInv);
				}
						ConMgr.clearAppCtx(null);
		}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (CPIMgr.getErrCode().equals("1"))
{
%>
	alert('<%=CPIMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(CPIMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

