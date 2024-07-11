<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.ControlInvasivo"%>
<%@ page import="issi.expediente.DetalleControl"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
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
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fecha_eval = request.getParameter("fecha_eval");
String filter1 = "";
String filter = "", op="", appendFilter = "";

String key = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	

	 iControl.clear();
sql="select to_char(fecha_registro,'dd/mm/yyyy') as fecha from tbl_sal_infeccion_paciente where pac_id="+pacId+" and secuencia="+noAdmision+"  and (pac_id,secuencia,fecha_registro) in (select pac_id, secuencia, fecha_inf from TBL_SAL_DETALLE_INFECCION) order by fecha_creacion desc";
al2 = SQLMgr.getDataList(sql);
			for (int i=1; i<=al2.size(); i++)
			{
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
			if(al2.size() == 0)
			{
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

	sql="SELECT a.codigo as codigoInfeccion, a.descripcion as descripcion, b.codigo as codigo, b.infec_pac as infecPac, to_char(b.fecha_inf,'dd/mm/yyyy') as fechaInf, to_char(b.fecha_ini,'dd/mm/yyyy') as fechaIni, to_char(b.fecha_cambio,'dd/mm/yyyy') as fechaCambio, to_char(b.fecha_retiro,'dd/mm/yyyy') as fechaRetiro, b.observacion as observacion, to_char(b.fecha_cultivo,'dd/mm/yyyy') as fechaCultivo, b.total_dias as totalDias, b.total_dias_cambio totalDiasCambio, decode(b.codigo,null,'I','U') status FROM TBL_SAL_INFECCION a, TBL_SAL_DETALLE_INFECCION b where a.codigo=b.codigo(+) and b.pac_id(+)="+pacId+" and b.secuencia(+)="+noAdmision+" and to_date(to_char(b.fecha_inf(+),'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+filter+"','dd/mm/yyyy') ORDER BY a.codigo ASC";
	al = SQLMgr.getDataList(sql);
	if (al.size() == 0 && control == null)
		if (!viewMode) modeSec = "add";
	else
			if (!viewMode) modeSec = "edit";

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
document.title = 'CONTROL DE PROCEDIMIENTOS INVASIVOS - '+document.title;
var noNewHeight = true;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function verControl(k){var fecha_e = eval('document.form0.fecha_evaluacion'+k).value ;window.location = '../expediente3.0/exp_ctrl_proc_invasivos.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval='+fecha_e;}
function doAction(){checkViewMode();}
function printRpt(){var fecha = document.form0.fechaRegistro.value;abrir_ventana1('../expediente/print_control_invasivos.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fechaControl='+fecha);}
function addControl(){window.location = '../expediente3.0/exp_ctrl_proc_invasivos.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>';}

$(function(){
})

function computeDayTotal(i) {
  var fi = $("#fechaIni"+i).val();
  var fc = $("#fechaCambio"+i).val();
  var fr = $("#fechaRetiro"+i).val();
  if (fi && !fc) {
    var d = getDBData('<%=request.getContextPath()%>',"trunc(sysdate) - to_date('"+fi+"','dd/mm/yyyy')",'dual','','');
    $("#totalDias"+i).val(d);
    console.log(1, d);
  } else if (fc && !fr) {
    var d = getDBData('<%=request.getContextPath()%>',"trunc(sysdate) - to_date('"+fc+"','dd/mm/yyyy') ",'dual','','');
    $("#totalDiasCambio"+i).val(d);
    console.log(2, d);
  } else if (fr && fi && fc) {
    var d1 = getDBData('<%=request.getContextPath()%>',"to_date('"+fr+"','dd/mm/yyyy') - to_date('"+fi+"','dd/mm/yyyy') ",'dual','','');
    var d2 = getDBData('<%=request.getContextPath()%>',"to_date('"+fr+"','dd/mm/yyyy') - to_date('"+fc+"','dd/mm/yyyy') ",'dual','','');
    $("#totalDias"+i).val(d1);
    $("#totalDiasCambio"+i).val(d2);
  }
}
function printRptXhora(){
    var fecha = document.form0.rpt_fecha.value;
    if(fecha) abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=expediente/rpt_procedimientos_invasivos.rptdesign&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&pCtrlHeader=true&tipo_desc=<%=desc%>&fecha='+fecha);
}
</script>
</head>
<body class="body-forminside" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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

<div class="headerform2">
    <table cellspacing="0" class="table pull-right table-striped table-custom-2">
    <tr>
      <td class="controls form-inline">
        <%=fb.button("imprimir","Imprimir",false,false,null,null,"onClick=\"javascript:printRpt()\"")%>
        <% if (!mode.equals("view") ){%>
          <button type="button" name="agregar" id="agregar" class="btn btn-inverse btn-sm" onclick="javascript:addControl()"><i class="fa fa-plus fa-lg"></i> Agregar</button>
        <%}%>
        
        <!--
        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />
        <jsp:param name="clearOption" value="true" />
        <jsp:param name="nameOfTBox1" value="rpt_fecha" />
        <jsp:param name="valueOfTBox1" value="<%=control.getFechaRegistro()%>" />
        </jsp:include>
        
        <button type="button" value="Imprimir" class="btn btn-inverse btn-sm" onclick="javascript:printRptXhora()"><i class="fa fa-print fa-lg"></i> Por Hora</button>
        -->
      </td>
    </tr>
    <tr class="bg-headtabla">
      <td>Listado de Evaluaciones</td>
    </tr>
    </table>
    
    <div class="table-wrapper">
       <table cellspacing="0" class="table table-small-font table-bordered table-striped">
           <tr class="bg-headtabla2">
             <td width="30%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
             <td width="70%"><cellbytelabel id="3">Observaci&oacute;n</cellbytelabel></td>
           </tr>
           <%if(appendFilter.equals("1") && !op.trim().equals("0")){%>
                <%=fb.hidden("fecha_evaluacion0",cDateTime.substring(0,10))%>
                <tr onClick="javascript:verControl(0)" class="pointer">
                    <td><%=cDateTime.substring(0,10)%></td>
                    <td><cellbytelabel id="4">Evaluaci&oacute;n actual</cellbytelabel></td>
                </tr>
            <%}%>
            <%al2 = CmnMgr.reverseRecords(iControl);
            for (int i=1; i<=iControl.size(); i++){
                key = al2.get(i-1).toString();
                cdo = (CommonDataObject) iControl.get(key);
            %> 
                <%=fb.hidden("fecha_evaluacion"+i,cdo.getColValue("fecha"))%>
                <tr class="pointer" onClick="javascript:verControl(<%=i%>)" >
                    <td><%=cdo.getColValue("fecha")%></td>
                    <td><%=cdo.getColValue("observacion")%></td>
                </tr>
            <%}%>
       </table>
    </div>
</div> 
<table cellspacing="0" class="table table-small-font table-bordered">   
    <tr class="bg-headtabla" align="center">
        <td width="25%"><cellbytelabel id="7">Procedimiento</cellbytelabel></td>
        <td><cellbytelabel id="8">Fecha de Inicio</cellbytelabel> </td>
        <td><cellbytelabel id="9">Fecha de cambio</cellbytelabel> </td>
        <td><cellbytelabel id="10">Fecha de cultivo</cellbytelabel> </td>
        <td><cellbytelabel id="11">Fecha de Retiro</cellbytelabel> </td>
        <td><cellbytelabel id="12">Total de D&iacute;as</cellbytelabel></td>
        <td><cellbytelabel id="12">T. D. Cambio</cellbytelabel></td>
    </tr>
    
    <tr>
      <td class="controls form-inline" colspan="7">
        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />
        <jsp:param name="clearOption" value="true" />
        <jsp:param name="fromLbl" value="Fecha" />
        <jsp:param name="nameOfTBox1" value="fechaRegistro" />
        <jsp:param name="valueOfTBox1" value="<%=control.getFechaRegistro()%>" />
        <jsp:param name="readonly" value="<%=(viewMode||(!modeSec.trim().equals("add")))?"y":"n"%>"/>
        </jsp:include>
      </td>
    </tr>
    <%for (int i=1; i<=al.size(); i++){
        cdo = (CommonDataObject) al.get(i-1);%>
        <%=fb.hidden("key"+i,key)%>
        <%=fb.hidden("remove"+i,"")%>
        <%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
        <%=fb.hidden("codigoInfeccion"+i,cdo.getColValue("codigoInfeccion"))%>
        <%=fb.hidden("fecha_infeccion"+i,control.getFechaRegistro())%>
        <%=fb.hidden("status"+i,cdo.getColValue("status"))%>

        <tr align="center">
            <td align="left"><%=cdo.getColValue("descripcion")%></td>
            <td class="controls form-inline">
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="<%="fechaIni"+i%>" />
                <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaIni")%>" />
                <jsp:param name="jsEvent" value="<%="computeDayTotal("+i+")"%>" />
                </jsp:include>
            </td>
            <td class="controls form-inline">
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="<%="fechaCambio"+i%>" />
                <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaCambio")%>" />
                <jsp:param name="jsEvent" value="<%="computeDayTotal("+i+")"%>" />
                </jsp:include>
             </td>
            <td class="controls form-inline">
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="<%="fechaCultivo"+i%>" />
                <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaCultivo")%>" />
                </jsp:include>
            </td>
            <td class="controls form-inline">
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="<%="fechaRetiro"+i%>" />
                <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaRetiro")%>" />
                <jsp:param name="jsEvent" value="<%="computeDayTotal("+i+")"%>" />
                </jsp:include>
            </td>
			<td><%=fb.textBox("totalDias"+i,cdo.getColValue("totalDias"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
			<td><%=fb.textBox("totalDiasCambio"+i,cdo.getColValue("totalDiasCambio"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
		</tr>
        <tr>
            <td valign="middle"align="right"><cellbytelabel id="3">Observaci&oacute;n</cellbytelabel>:</td>
            <td colspan="6"><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
        </tr>
<%
}
%>
</table>

<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
            <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
            <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
        </tr>
    </table>   
</div>

<%=fb.formEnd(true)%>
</div>
</div>
</div>
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
        
        if(modeSec.equalsIgnoreCase("add")){
            controlInv.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
            controlInv.setFechaCreacion(request.getParameter("fechaCreacion"));
            controlInv.setUsuarioModificacion(UserDet.getUserName());
            controlInv.setFechaModificacion(cDateTime);
        } else {
            controlInv.setUsuarioModificacion(UserDet.getUserName());
            controlInv.setFechaModificacion(cDateTime);
        }
        
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
				detCon.setTotalDiasCambio(request.getParameter("totalDiasCambio"+i));
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

