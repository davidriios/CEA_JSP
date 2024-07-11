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
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
CONTAB0056					CONTABILIDAD\MAYOR GENERAL\PROCESOS\INICIO SISTEMA
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");

if(fg==null) fg = "anio";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
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
document.title = 'Contabilidad - '+document.title;

function doSubmit(value){document.form1.baction.value = value;}
function doAction(){}
function eject(){
	var anio = document.form1.anio.value;
	var mes = document.form1.mes.value;
	var p_compania = '<%=(String) session.getAttribute("_companyId")%>';
	var v_user = '<%=(String) session.getAttribute("_userName")%>';
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	if(confirm('DESEA CONTINUAR CON EL PROCESO DE INICIALIZACION!')){
	var v_anios = getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_estado_anos','cod_cia=<%=(String) session.getAttribute("_companyId")%> '); 
	if(parseInt(v_anios) == 0 ){
		if(executeDB('<%=request.getContextPath()%>','call sp_con_iniciar_sistema(' + p_compania + ', ' + anio + ', \'' + v_user + '\','+mes+')')){
			var msg = 'El proceso de Inicialización se realizó satisfactoriamente!';//getMsg('<%=request.getContextPath()%>', clientIdentifier);
			alert(msg);
		} else alert('El proceso de Inicialización no pudo realizarse!');
		}else alert('No puede iniciar Sistema. Ya existen registros para la Compañia. El proceso correcto es Realizar el cierre Anual(Transitorio)');
	}
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INICIO DE SISTEMA"></jsp:param>
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
										<%=fb.hidden("clearHT","")%>
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                          <tr class="TextPanel">
                            <td>
                            Inicio del Sistema
                            </td>
                          </tr>
                          <tr class="TextHeader02">
                            <td>Este proceso realiza la inicialización del Sistema de Contabilidad
Introduzca el año  a iniciar  y presione el botón de INICIAR<br><font color="#FF0000" size="+1">Solo se realiza al inicio de la implementacion.</font></td>
                          </tr>
                          <tr class="textRow01">
                            <td>A&ntilde;o:
                            <%=fb.textBox("anio","",true,false,false,10)%>&nbsp;&nbsp;&nbsp;Mes: &nbsp; <%=fb.textBox("mes","1",true,false,false,10)%>
                            <%=fb.button("btnuso","INICIAR",true,false,"Text10",null,"onClick=\"javascript:eject();\"")%>
                            </td>
                        </table></td>
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
%>
