<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario*** */

UserDet = SecMgr.getUserDetails(session.getId());  /* *** quitar el comentario **** */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", status = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reporte de Admision- '+document.title;
function doAction()
{
}

function showReporte(value,fg)
{
  var categoria    = document.form0.categoria.value;
  var tipoAdmision = document.form0.tipoAdmision.value;
  var area         = document.form0.area.value;
  var aseguradora  = document.form0.aseguradora.value;
  var fechaini     = document.form0.fechaini.value;
  var fechafin     = document.form0.fechafin.value;
  var tipoRep     = document.form0.tipoRep.value;
  var titulo=""; 
  var pCtrlHeader = document.form0.pCtrlHeader.checked;
  
  if(value=="1")titulo = "CATEGORIA DE ADMISION";
  else if(value=="2")titulo = "TIPO DE ADMISION";
  else if(value=="3")titulo = "PACIENTE";
  else if(value=="4")titulo = "ASEGURADORA";
  
  if(tipoRep=="R")  titulo += " - RESUMIDO";
 

 if(fg=='PDF')abrir_ventana2('../facturacion/print_adm_facturadas.jsp?tipoRep='+tipoRep+'&categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&groupBy='+value+'&titulo='+titulo);
 else {
 
 var fdArray = fechaini.split("/");
	var fhArray = fechafin.split("/");
	fechaini = fdArray[2]+"-"+fdArray[1]+"-"+fdArray[0];
	fechafin = fhArray[2]+"-"+fhArray[1]+"-"+fhArray[0];
	
  if(tipoRep=="R")abrir_ventana('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_fac_adm_facturadas_res.rptdesign&pCtrlHeader='+pCtrlHeader+'&pCategoria='+categoria+'&pTipoAdmision='+tipoAdmision+'&pArea='+area+'&pAseguradora='+aseguradora+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pGroupBy='+value+'&pTitulo='+titulo);
  else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_fac_adm_facturadas_det.rptdesign&pCtrlHeader='+pCtrlHeader+'&pCategoria='+categoria+'&pTipoAdmision='+tipoAdmision+'&pArea='+area+'&pAseguradora='+aseguradora+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pGroupBy='+value+'&pTitulo='+titulo);
  
  }
 
 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="REPORTES DE INGRESOS / EGRESOS DE PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td><%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
      <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
      <%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%> <%=fb.hidden("baction","")%>
  <tr>
    <td><table align="center" width="70%" cellpadding="0" cellspacing="1">
        <tr>
          <td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
              <tr class="TextFilter" >
                <td width="8"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
                <td width="92%"><%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%> </td>
              </tr>
              <tr class="TextFilter">
                <td width="8%"><cellbytelabel>Tipo Admisi&oacute;n</cellbytelabel></td>
                <td width="92%"><%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo tipoAdmision from tbl_adm_tipo_admision_cia order by 2","tipoAdmision",tipoAdmision,"T")%> </td>
              </tr>
              <tr class="TextFilter">
                <td width="8%"><cellbytelabel>&Aacute;rea de Servicio</cellbytelabel></td>
                <td width="92%"><%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A' and si_no = 'S' and compania_unorg = "+(String)session.getAttribute("_companyId")+" union select 0,'CUARTOS DE URGENCIA'||'-'||0 from dual order by 2","area",area,"T")%> </td>
              <tr class="TextFilter">
                <td width="8%"><cellbytelabel>Aseguradora</cellbytelabel></td>
                <td width="92%"><%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa where tipo_empresa = 2 order by 2","aseguradora",aseguradora,"T")%> </td>
              </tr>
              <tr class="TextFilter" >
                <td width="25%"><cellbytelabel>Fecha</cellbytelabel></td>
                <td width="75%"> <cellbytelabel>Desde</cellbytelabel> &nbsp;&nbsp;
                  <jsp:include page="../common/calendar.jsp" flush="true">
                  <jsp:param name="noOfDateTBox" value="1" />
                  <jsp:param name="clearOption" value="true" />
                  <jsp:param name="nameOfTBox1" value="fechaini" />
                  <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
                  </jsp:include>
                  <cellbytelabel>Hasta</cellbytelabel> &nbsp;&nbsp;
                  <jsp:include page="../common/calendar.jsp" flush="true">
                  <jsp:param name="noOfDateTBox" value="1" />
                  <jsp:param name="clearOption" value="true" />
                  <jsp:param name="nameOfTBox1" value="fechafin" />
                  <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
                  </jsp:include>
                </td>
              </tr>
            </table>
            <table align="center" width="100%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader">
                <td colspan="2"><cellbytelabel>Tipo de Reporte</cellbytelabel>:&nbsp;<%=fb.select("tipoRep","D=Detallado, R=Resumido","", false, false, 0, "text10", "", "", "", "")%> 
				&nbsp;&nbsp;&nbsp;&nbsp;Esconder Cabecera?<%=fb.checkbox("pCtrlHeader","false")%>
				</td>
              </tr>
              <tr class="TextHeader">
                <td colspan="2"><cellbytelabel>Agrupar por</cellbytelabel></td>
              </tr>
              <authtype type='50'>
                <tr class="TextRow01">
                  <td width="15%"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value,'PDF')\"")%><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
				  <td width="85%"><a href="javascript:showReporte(1,'EX')" class="Link00"> Excel </a></td>
                </tr>
              </authtype>
              <authtype type='51'>
                <tr class="TextRow01">
                  <td><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value,'PDF')\"")%><cellbytelabel>Tipo de Admisi&oacute;n</cellbytelabel></td>
				  <td> <a href="javascript:showReporte(2,'EX')" class="Link00"> Excel </a></td>
                </tr>
              </authtype>
              <authtype type='52'>
                <tr class="TextRow01">
                  <td ><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value,'PDF')\"")%>Paciente</td>
				  <td><a href="javascript:showReporte(3,'EX')" class="Link00"> Excel </a></td>
                </tr>
              </authtype>
              <authtype type='53'>
                <tr class="TextRow01">
                  <td><%=fb.radio("reporte1","4",false,false,false,null,null, "onClick=\"javascript:showReporte(this.value,'PDF')\"")%>Aseguradora</td>
				  <td><a href="javascript:showReporte(4,'EX')" class="Link00"> Excel </a></td>
                </tr>
              </authtype>
              <%=fb.formEnd(true)%>
            </table>
            <!-- ================================   F O R M   E N D   H E R E   ================================ -->
          </td>
        </tr>
      </table></td>
  </tr>
  </td>
  
  </tr>
  
</table>
</body>
</html>
<%
}//GET
%>
