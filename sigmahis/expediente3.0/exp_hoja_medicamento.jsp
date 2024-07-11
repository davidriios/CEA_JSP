<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.expediente.HojaMedicamento"%>
<%@ page import="issi.expediente.HojaMedicamentoDet"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="HashMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vMed" scope="session" class="java.util.Vector" />
<jsp:useBean id="HMMgr" scope="page" class="issi.expediente.HojaMedicamentoMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
HMMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
HojaMedicamento hm = new HojaMedicamento();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fecha = request.getParameter("fecha");
String hora = request.getParameter("hora");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");

int lastLineNo = 0;
String key = "";

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET")){

  HashMed.clear();
  vMed.clear();

	if (modeSec.equalsIgnoreCase("add"))
	{
		String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
		hm.setFecha(cDate.substring(0,10));
		hm.setHora(cDate.substring(11));
	}
	else
	{
		if (fecha == null || hora == null) throw new Exception("La Fecha y Hora no son válidas. Por favor intente nuevamente!");
		hm.setFecha(fecha);
		hm.setHora(hora);

		sql=" select a.cod_paciente codPaciente, to_char(a.fec_nacimiento,'dd/mm/yyyy') fecNacimiento, a.secuencia, to_char(a.fecha,'dd/mm/yyyy') fecha,to_char(a.hora,'hh12:mi am') hora, a.emp_provincia empProvincia, a.emp_sigla empSigla, a.emp_tomo empTomo, a.emp_asiento empasiento, a.emp_compania empCompania, a.tipo_personal tipoPersonal, a.personal_g personalG, a.emp_id empId from  tbl_sal_medicamento_admision a where a.pac_id = "+pacId+"and a.secuencia = "+noAdmision+"  and to_char(a.fecha,'dd/mm/yyyy')='"+fecha+"' and to_date(to_char(a.hora,'hh12:mi am'),'hh12:mi am')=to_date('"+hora+"','hh12:mi am') ";

		hm = (HojaMedicamento) sbb.getSingleRowBean(ConMgr.getConnection(), sql, HojaMedicamento.class);

		sql = " select  a.codigo, to_char(a.hora,'hh12:mi am') hora ,medicamento,a.dosis, a.via,a.frecuencia,a.observacion,a.dosis_desc as dosisDesc from tbl_sal_detalle_medicamento a where a.pac_id = "+pacId+"and a.secuencia = "+noAdmision+"  and to_date(to_char(a.fecha_medica,'dd/mm/yyyy'),'dd/mm/yyyy')= to_date('"+fecha+"','dd/mm/yyyy') and to_date(to_char(a.hora_medica,'hh12:mi am'),'hh12:mi am')=to_date('"+hora+"','hh12:mi am') order by a.codigo";

		al = sbb.getBeanList(ConMgr.getConnection(),sql,HojaMedicamentoDet.class);

		lastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			HojaMedicamentoDet det = (HojaMedicamentoDet) al.get(i - 1);

			if (i < 10) key = "00"+i;
			else if (i < 100) key = "0"+i;
			else key = ""+i;
			det.setKey(key);

			try
			{
				HashMed.put(key, det);
				vMed.add(det.getMedicamento());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}
%>
<!DOCTYPE html>
<html lang="en"> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
document.title = 'Hoja de medicamento - '+document.title;
function doAction(){}
function imprimirMedicamento(){abrir_ventana1('../expediente/print_hoja_medicamento.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&exp=3');}
function viewMedicamento(k){abrir_ventana1('../expediente/hoja_medicamento_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&exp=3');}
function add(){window.location = '../expediente3.0/exp_hoja_medicamento.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>';}
function verActivos(){abrir_ventana1('../expediente/exp_orden_medicamentos_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=A&exp=3');}
function verOmitidos(){abrir_ventana1('../expediente/exp_orden_medicamentos_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=O&exp=3');}
function doSubmit(formName,bAction){parent.setPatientInfo(formName,'iDetalle');setBAction(formName,bAction);window.frames['iDetalle'].doSubmit();}

function verAdm(fecha, hora) {
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=view&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&fecha='+fecha+'&hora='+hora;
}

function verHistorial() {
  $("#hist_container").toggle();
}

$(function(){
  $('iframe').iFrameResize({
    log: false
  });
});
</script>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("cds",""+cds)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>

<div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-1">
		<tr class="TextRow02">
			<td align="right">
			
        <!--<button type="button" class="btn btn-inverse btn-sm" onClick="verHistorial()">
           <i class="fa fa-eye"></i> <b>Historial</b>
        </button>-->
                
        <%if(!mode.trim().equalsIgnoreCase("view")){%>
         <button type="button" name="activos" id="activos" class="btn btn-inverse btn-sm" onClick="javascript:add()"><i class="fa fa-plus fa-lg"></i>Agregar</button>
        <%}%>
        
        <button type="button" name="activos" id="activos" class="btn btn-inverse btn-sm" onClick="javascript:verActivos()"><i class="fa fa-eye fa-lg"></i> Ver Medic. Activos</button>
    
        <button type="button" name="omitidos" id="omitidos" class="btn btn-inverse btn-sm" onClick="javascript:verOmitidos()"><i class="fa fa-eye fa-lg"></i> Ver Medic. Omitidos</button>
                
        <button type="button" name="consultar" id="consultar" class="btn btn-inverse btn-sm" onClick="javascript:viewMedicamento()"><i class="fa fa-eye fa-lg"></i> Consultar</button>
        
        
        <button type="button" name="imprimir" id="imprimir" class="btn btn-inverse btn-sm" onClick="javascript:imprimirMedicamento()"><i class="fa fa-print fa-lg"></i> Imprimir</button>
			</td>
		</tr>
    </table>
    
    <%
    CommonDataObject cdoH = SQLMgr.getData("select to_char(a.fecha, 'dd/mm/yyyy') as fecha, to_char(a.hora, 'hh:mi am') as hora,(SELECT LISTAGG(b.medicamento, '<br>') WITHIN GROUP (ORDER BY b.medicamento DESC) FROM tbl_sal_detalle_medicamento b where b.pac_id = a.pac_id and b.secuencia = a.secuencia and b.fecha_medica = a.fecha and b.hora_medica = a.hora) medicamentos from tbl_sal_medicamento_admision a where a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+" and a.fecha_creacion = (select max(fecha_creacion) from tbl_sal_medicamento_admision where pac_id = "+pacId+" and secuencia = "+noAdmision+" )");
    if (cdoH == null) cdoH = new CommonDataObject();
    %>
    
    <div class="table-wrapper" id="hist_container" style="display:none;">
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
            <thead>
                <tr>
                    <th colspan="7" class="bg-headtabla">&Uacute;ltima administraci&oacute;n</th>
                </tr> 
                
                <tr class="bg-headtabla2">
                    <td>Fecha</td>
                    <td>Hora</td>
                    <td>Medicamentos</td>
                </tr>
                <tr class="pointer" onClick="javascript:verAdm('<%=cdoH.getColValue("fecha")%>','<%=cdoH.getColValue("hora")%>')">
                  <td><%=cdoH.getColValue("fecha")%></td>
                  <td><%=cdoH.getColValue("hora")%></td>
                  <td><%=cdoH.getColValue("medicamentos")%></td>
                </tr> 
             </thead> 
          </table> 
    </div>



</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
    <tr>
        <td width="25%" align="right"><cellbytelabel id="6">Fecha</cellbytelabel></td>
        <td width="25%" class="controls form-inline">
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="fecha" />
            <jsp:param name="valueOfTBox1" value="<%=hm.getFecha()%>" />
            <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
            </jsp:include>
        </td>
            
        <td width="25%" align="right"><cellbytelabel id="7">Hora</cellbytelabel></td>
        <td width="25%" class="controls form-inline">
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="format" value="hh12:mi am" />
            <jsp:param name="nameOfTBox1" value="hora" />
            <jsp:param name="valueOfTBox1" value="<%=hm.getHora()%>" />
            <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
            </jsp:include>
        </td>
	</tr>

    <tr>
        <td colspan="4"><iframe name="iDetalle" id="iDetalle" width="100%" scrolling="yes" frameborder="0" src="../expediente3.0/exp_hoja_medicamento_det.jsp?seccion=<%=seccion%>&mode=<%=mode%>&modeSec=<%=modeSec%>&cds=<%=cds%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&lastLineNo=<%=lastLineNo%>"></iframe></td>
    </tr>
</table>

<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td>
                <small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                <%=fb.button("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:doSubmit('"+fb.getFormName()+"',this.value)\"")%>
                <button type="button" class="btn btn-inverse btn-sm" onClick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>
            </td>
        </tr>
    </table>   
</div>
   
<%=fb.formEnd(true)%>
</div>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	HMMgr.setErrCode(request.getParameter("errCode"));
	HMMgr.setErrMsg(request.getParameter("errMsg"));
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (HMMgr.getErrCode().equals("1"))
{
%>
	alert('<%=HMMgr.getErrMsg()%>');
<%
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
	parent.parent.doRedirect(0);
<%
	}
} else throw new Exception(HMMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&lastLineNo=<%=lastLineNo%>&cds=<%=cds%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&lastLineNo=<%=lastLineNo%>&fecha=<%=request.getParameter("fecha")%>&hora=<%=request.getParameter("hora")%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>

