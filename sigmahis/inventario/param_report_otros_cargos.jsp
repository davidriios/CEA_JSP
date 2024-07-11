
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
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" /><%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String almacen = request.getParameter("almacen");
String compania = request.getParameter("compania");

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String caja = "";

if (mode == null) mode = "add";
if (compania == null) compania = (String) session.getAttribute("_companyId");

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
document.title = 'Reporte de Inventario- '+document.title;
function doAction()
{
}

function showReporte(value){

	var msg = '';
	var company = document.form0.compania.value ;
	var almacen = document.form0.almacen.value ;
	var fechaI = document.form0.fechaI.value ;
	var fechaF = document.form0.fechaF.value ;
	var consignacion = document.form0.consignacion.value ;

	if(fechaI == '' || fechaF == '') msg = 'fechas de Inicio y Final!';
	else if(almacen == '') msg = 'almacén!';
	if(msg == ''){
		if(value=="1") abrir_ventana('../inventario/print_fact_otros_clientes.jsp?compania='+company+'&almacen='+almacen+'&fechaI='+fechaI+'&fechaF='+fechaF+'&consignacion='+consignacion);
	} else alert('Seleccione '+msg);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="REPORTES DE INVENTARIO"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="1">
        <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
        <%=fb.formStart(true)%> 
				<%=fb.hidden("mode",mode)%> 
				<%=fb.hidden("baction","")%>
        <tr class="TextFilter">
          <td colspan="2">Fecha Inicio
            <jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="fechaI" />
					<jsp:param name="valueOfTBox1" value="" />
					</jsp:include>
            &nbsp;
            Fecha Final:
            <jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="fechaF" />
					<jsp:param name="valueOfTBox1" value="" />
					</jsp:include>
          </td>
        </tr>
        <tr class="TextFilter">
          <td width="100%">Compañia<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacen','"+almacen+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S')\"")%> </td>
        </tr>
        <tr class="TextFilter">
          <td width="50%"> Almacen <%=fb.select("almacen","","")%>
            <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','S');
			</script>
          </td>
        </tr>
        <tr class="TextFilter">
          <td colspan="2">Consignaci&oacute;n &nbsp;&nbsp;<%=fb.select("consignacion","S=SI,N=NO","",false,false,0,"",null,null,null,"T")%></td>
        </tr>
      </table></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr>
          <td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader">
                <td colspan="2" align="center">Reportes</td>
              </tr>
              <tr class="TextRow01">
                <td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Facturacion Otros Clientes</td>
              </tr>
              <%fb.appendJsValidation("if(error>0)doAction();");%>
              <%=fb.formEnd(true)%>
            </table>
            <!-- ================================   F O R M   E N D   H E R E   ================================ -->
          </td>
        </tr>
      </table></td>
  </tr>
</table>
</body>
</html>
<%
}//GET
%>

