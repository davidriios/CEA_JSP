<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htextra" scope="session" class="java.util.Hashtable" />

<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);


SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList sec = new ArrayList();
String key = "";
String sql = "";
String appendFilter = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String anio = request.getParameter("anio");
String planilla = request.getParameter("planilla");
String periodo = request.getParameter("periodo");
String seccion = request.getParameter("seccion");

String empId = request.getParameter("empid");
String trxId = request.getParameter("trx");
String usuario = (String) session.getAttribute("_userName"); 
String fecha = request.getParameter("fecha");

String fechaIngreso="";
int benLastLineNo = 0, prioridad = 0;
String compania = (String) session.getAttribute("_companyId"); 
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anioC = CmnMgr.getCurrentDate("yyyy");
String mes = CmnMgr.getCurrentDate("mm");
String dia = CmnMgr.getCurrentDate("dd");
int per = 0;
double total = 0.00;
int iconHeight = 48;
int iconWidth = 48;
boolean viewMode = true;

int day = Integer.parseInt(CmnMgr.getCurrentDate("dd"));
int mont = Integer.parseInt(CmnMgr.getCurrentDate("mm"));

if(day >16) per = mont*2;
else per =  mont*2-1;

	if (anio == null) anio = anioC;	
	if (periodo == null) periodo = ""+per;
	if (planilla == null) planilla = "1";
	if (fecha == null) fecha = "";
	
	/*
if(dia >= '16') periodo = parseInt(mes, 10) * 2 - 1;
		else periodo = parseInt(mes, 10) * 2;
*/	
sec = sbb.getBeanList(ConMgr.getConnection(), "select codigo as optValueColumn, descripcion as optLabelColumn from tbl_sec_unidad_ejec where codigo <= 100 and nivel = 3 and compania="+(String) session.getAttribute("_companyId")+" order by descripcion", CommonDataObject.class);

		
if (tab == null) tab = "0";
if (mode == null) mode = "add";
if(mode.equals("view")) viewMode = false;

if (request.getParameter("benLastLineNo") != null) benLastLineNo = Integer.parseInt(request.getParameter("benLastLineNo"));
CommonDataObject cdoTot = new CommonDataObject();
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
document.title = 'Planilla - '+document.title;

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}

function doAction()
{

}

function acreedor()
{
abrir_ventana('../common/search_acreedor.jsp?fp=sindicato');
}

function grupo()
{
abrir_ventana('../common/search_grupo_descuento.jsp?fp=sindicato');
}



function cargaDesc()
{
var msg = '';
var fAcr     =  document.form_0.acrCode.value;
var fGrp     =  document.form_0.grpCode.value;
var p_user   =  document.form_0.usuario.value; 
var monto    =  document.form_0.cuota.value;
var codigo = 'N';

if(fAcr == "") 
msg += ' un Acreedor , Verifique .....';
if(fGrp == "") 
msg += ' un Grupo , Verifique .....';
if(monto == "") 
msg += ' un Monto a descontar , Verifique .....';

if(msg == '')
{
 

if(confirm('Se Generará el Descuento por Cuota Extraordinaria del Sindicato .... Desea Continuar...'))
	{

if(executeDB('<%=request.getContextPath()%>','call sp_pla_descuento_sind(\''+monto+'\',<%=compania%>,'+fAcr+','+fGrp+',\''+p_user+'\')'))
		{
		alert('Descuentos por Cuota de Sindicato Generados ... Satisfactoriamente!');	
		window.opener = '<%=request.getContextPath()%>/rhplanilla/list_desc_sindicato.jsp';
				
		} else alert('No se ha podido generar los Descuento...Consulte al Administrador!');
	}

	} //msg 
	else alert('Seleccione '+msg);
	
}



</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr class="TextRow02">
  <td>&nbsp;</td>
</tr>
<tr class="TextRow02">
  <td>&nbsp;</td>
</tr>

<tr>
  <td>
    <table width="100%" cellpadding="1" cellspacing="0">

<%fb = new FormBean("form_0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("extraSize",""+htextra.size())%> 
<%=fb.hidden("usuario",usuario)%>

 
 
  <tr class="TextHeader">
      <td colspan="2" align="center">
       GENERAR DESCUENTOS POR CUOTA EXTRAORDINARIA DEL SINDICATO
		<br> 
		<br> Descuento por Cuota Extraordinaria de Sindicato &nbsp;
		<br> 
		       
			</td>
  </tr>
 
   <tr class="TextHeader">
      <td align="right">
       Acreedor : 
			</td>
			  <td align="left">
      				<%=fb.intBox("acrCode","",false,false,true,5,4)%> 
						  <%=fb.textBox("acrDesc","",false,false,true,35)%> 
						  <%=fb.button("btnacr","Ir",false,false,null,null,"onClick=\"javascript:acreedor()\"")%>
			</td>
    </tr>
	
	 <tr class="TextRow01">
      <td colspan="2" align="center">&nbsp;
       
	  </td>
    </tr>
		
		 <tr class="TextHeader">
      <td align="right">
       Grupo de Descuento : 
			</td>
			 <td align="left">
              <%=fb.intBox("grpCode","",false,false,true,5,4)%> 
						  <%=fb.textBox("grpDesc","",false,false,true,35)%> 
						  <%=fb.button("btngrp","Ir",true,false,null,null,"onClick=\"javascript:grupo()\"")%>
			</td>
    </tr>
	
	
	 <tr class="TextRow01">
      <td colspan="2" align="center">&nbsp;
       
		  </td>
    </tr>
	
	 <tr class="TextHeader">
      <td align="right">
       Valor de la Cuota :  
			</td>
			  <td align="left">
       <%=fb.textBox("cuota","",false,false,false,5)%> 
			</td>
    </tr>
		
		 <tr class="TextRow01">
      <td colspan="2" align="center">&nbsp;
       
	  </td>
    </tr>
	
	 <tr class="TextHeader">
      <td colspan="2" align="center">
			 GENERAR DESCUENTOS POR CUOTA EXTRAORDINARIA DEL SINDICATO
		<br> 
     <%=fb.button("go","..Generar Desc...",false,false,"Text10",null,"onClick=\"javascript:cargaDesc()\"")%>
		 
		</td>
    </tr>
		
	
	
	<%=fb.formEnd(true)%>
	</table>
  </td>
</tr>

</table>

<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
} //GET
else
{


  
%> 
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (tab.equals("0"))
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_desc_sindicato.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_desc_sindicato.jsp")%>';
	
	window.close();
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_desc_sindicato.jsp';
	window.close();
<%
		}
	}

	} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');

	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_desc_sindicato.jsp';

	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
