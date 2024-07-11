<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
INV950128						INVENTARIO\TRANSACCIONES\CODIGOS AXA.																				ENLACE DEL CODIGO DEL MEDICAMENTO CON LOS CODIGOS DE AXA.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEmpMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
emp.clear();
empKey.clear();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String emp_id = request.getParameter("emp_id");
if(fg==null) fg = "";
if(fp==null) fp = "";
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
CommonDataObject emple = new CommonDataObject();
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		sql = "select provincia, sigla, tomo, asiento, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido from tbl_pla_empleado em where emp_id = " + emp_id;
		emple = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Facturación - '+document.title;

function doSubmit(value){
	window.frames['itemFrame'].document.form.baction.value = value;
	window.frames['itemFrame'].doSubmit(value);
}


function doAction(){
}

function imprimir(){
	abrir_ventana('../inventario/print_list_articulos_axa.jsp');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="NOTAS DE EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
              <tr>
                <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
                    <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                    <%=fb.formStart(true)%> 
										<%=fb.hidden("mode",mode)%> 
										<%=fb.hidden("errCode","")%> 
										<%=fb.hidden("errMsg","")%> 
										<%=fb.hidden("baction","")%> 
										<%=fb.hidden("fg",fg)%> 
										<%=fb.hidden("fp",fp)%> 
										<%=fb.hidden("clearHT","")%> 
										<%=fb.hidden("saveOption","")%>
                    <%=fb.hidden("emp_id",emp_id)%>
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextRow01">
                          <td>&nbsp;C&eacute;dula</td>
                          <td>
													<%=fb.intBox("provincia",emple.getColValue("provincia"),false,mode.equals("edit"),false,5,2,null,null,"")%> 
													<%=fb.textBox("sigla",emple.getColValue("sigla"),false,mode.equals("edit"),false,5,2,null,null,"")%> 
													<%=fb.intBox("tomo",emple.getColValue("tomo"),false,mode.equals("edit"),false,5,4,null,null,"")%> 
													<%=fb.intBox("asiento",emple.getColValue("asiento"),false,mode.equals("edit"),false,5,5,null,null,"")%> 
                          </td>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                        </tr>
                        <tr class="TextRow01" >
                          <td width="17%">&nbsp;Primer Nombre</td>
                          <td width="33%"><%=fb.textBox("primer_nombre",emple.getColValue("primer_nombre"),false,false,false,30,30)%></td>
                          <td width="20%">&nbsp;&nbsp;&nbsp;&nbsp;Segundo Nombre</td>
                          <td width="30%"><%=fb.textBox("segundo_nombre",emple.getColValue("segundo_nombre"),false,false,false,30,30)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Primer Apellido</td>
                          <td><%=fb.textBox("primer_apellido",emple.getColValue("primer_apellido"),false,false,false,30,30)%></td>
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Segundo Apellido</td>
                          <td><%=fb.textBox("segundo_apellido",emple.getColValue("segundo_apellido"),false,false,false,30,30)%></td>
                        </tr>
                      </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="300" scrolling="yes" src="../rhplanilla/reg_notas_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&emp_id=<%=emp_id%>"></iframe></td>
                    </tr>
                    <tr class="TextRow02">
                      <td align="right">
											<%=fb.button("save","Guardar",true,false,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
                      </td>
                    </tr>
                    <%=fb.formEnd(true)%>
                    <!-- ================================   F O R M   E N D   H E R E   ================================ -->
                  </table></td>
              </tr>
            </table></td>
        </tr>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");
	if (request.getParameter("baction").equalsIgnoreCase("Guardar") || request.getParameter("baction").equalsIgnoreCase("cerrar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}
	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
<%
	if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
%>	
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fg=<%=fg%>&emp_id=<%=request.getParameter("emp_id")%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
