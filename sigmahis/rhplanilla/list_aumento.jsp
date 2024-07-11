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
function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
function doAction(){}
function verAum()
{
var msg = '';
var fProc    =  document.form_0.fecha.value;
var p_user   =  document.form_0.usuario.value;
var codigo = 'N';

if(fProc == "")
msg += ' la fecha , Verifique .....';
if(msg == '')
{
 if(hasDBData('<%=request.getContextPath()%>','tbl_pla_aumento_cc',' compania='+<%=compania%>+' and tipo_aumento = 1 /*and actualizado =  \''+codigo+'\'*/ and trunc(fecha_aumento) = to_date(\''+fProc+'\',\'dd/mm/yyyy\')  ',''))
     {
			eval('document.form_0.go').disabled = true;
			eval('document.form_0.gover').disabled = false;
			eval('document.form_0.goeli').disabled = false;
			eval('document.form_0.goact').disabled = false;
	 		} else
      {
			eval('document.form_0.go').disabled = false;
			eval('document.form_0.gover').disabled = true;
			eval('document.form_0.goeli').disabled = true;
			eval('document.form_0.goact').disabled = true;
			}
	} //msg
else alert('Seleccione '+msg);
}

function cargaAum()
{
var msg = '';
var fProc    =  document.form_0.fecha.value;
var p_user   =  document.form_0.usuario.value;
var codigo = 'N';

if(fProc == "")
msg += ' la fecha , Verifique .....';
if(msg == '')
{
 if(hasDBData('<%=request.getContextPath()%>','tbl_pla_aumento_cc',' compania='+<%=compania%>+' and tipo_aumento = 1 and actualizado = \''+codigo+'\' and trunc(fecha_aumento) = to_date(\''+fProc+'\',\'dd/mm/yyyy\')  ',''))
     {
			eval('document.form_0.go').disabled = true;
			eval('document.form_0.gover').disabled = false;
			eval('document.form_0.goeli').disabled = false;
			eval('document.form_0.goact').disabled = false;
	 }
else {
	if(confirm('Se Generará el Aumento por Convención Colectiva .... Desea Continuar...'))
	{
		showPopWin('../common/run_process.jsp?fp=AUMG&actType=50&docType=AUMG&docId='+fProc+'&docNo='+fProc+'&compania=<%=(String) session.getAttribute("_companyId")%>&fecha='+fProc,winWidth*.75,winHeight*.65,null,null,'');
	}else alert('Proceso Cancelado!');
	}
	} //msg
else alert('Seleccione '+msg);

}

function elimina()
{
var msg = '';
var codigo = 'N';
var fProc    =  document.form_0.fecha.value;
var p_user   =  document.form_0.usuario.value;

if(confirm('Está seguro que desea Eliminar los Aumento por Convención Colectiva para esta Fecha.... Desea Continuar...'))
	{
	showPopWin('../common/run_process.jsp?fp=AUMG&actType=52&docType=AUMG&docId='+fProc+'&docNo='+fProc+'&compania=<%=(String) session.getAttribute("_companyId")%>&fecha='+fProc,winWidth*.75,winHeight*.65,null,null,'');
	/*
   if(executeDB('<%=request.getContextPath()%>','delete from tbl_pla_aumento_cc where compania = <%=compania%> and actualizado = \''+codigo+'\' and tipo_aumento = 1 and trunc(fecha_aumento) = to_date(\''+fProc+'\',\'dd/mm/yyyy\') ','tbl_pla_aumento_cc'))
		{
		alert('Aumentos por Convención Colectiva Eliminados ... Satisfactoriamente!');
		eval('document.form_0.go').disabled = false;
			eval('document.form_0.gover').disabled = true;
			eval('document.form_0.goeli').disabled = true;
			eval('document.form_0.goact').disabled = true;
			window.opener = '<%=request.getContextPath()%>/rhplanilla/list_aumento.jsp';

    }  else alert('No se ha podido eliminar los Aumentos...Consulte al Administrador!');*/
}  else alert('Cancelado por el usuario la eliminación de los Aumentos...!');
}

function detalle()
{

var fechaDet=document.form_0.fecha.value;
abrir_ventana('../rhplanilla/pago_aumento_list.jsp?fecha='+fechaDet);
}

function actualiza()
{
var msg = '';
var codigo = 'N';
var fProc    =  document.form_0.fecha.value;
var p_user   =  document.form_0.usuario.value;
if(confirm('Está seguro que desea Actualizar los Aumento por Convención Colectiva para esta Fecha.... Desea Continuar...'))
	{
  showPopWin('../common/run_process.jsp?fp=AUMG&actType=53&docType=AUMG&docId='+fProc+'&docNo='+fProc+'&compania=<%=(String) session.getAttribute("_companyId")%>&fecha='+fProc,winWidth*.75,winHeight*.65,null,null,'');
  /*
  if(executeDB('<%=request.getContextPath()%>','call sp_pla_actualizar_aumentos(<%=compania%>,\''+fProc+'\',\'1\',\''+p_user+'\')'))
		{
		alert('Aumentos por Convención Colectiva Actualizados ... Satisfactoriamente!');
		  eval('document.form_0.go').disabled    = true;
			eval('document.form_0.gover').disabled = true;
			eval('document.form_0.goeli').disabled = true;
			eval('document.form_0.goact').disabled = true;
			window.opener = '<%=request.getContextPath()%>/rhplanilla/list_aumento.jsp';

    }  else alert('No se ha podido actualizar los Aumentos...Consulte al Administrador!');*/
	}  else alert('Cancelado por el usuario la actualización de los Aumentos...!');
}


function refreshFecha(k)
{
var msg = '';
var anio = '';
var mes = '';
var dia = '';
var fCon    =  document.form_0.fechaCon.value;
var fProc    =  document.form_0.fechaCon.value;
var p_user   =  document.form_0.usuario.value;
var codigo = 'N';

	fdia = k.substring(0,2);
	fmes = k.substring(3,5);
	fanio = k.substring(6,10);
	//fanio = k.substring(0,4);
	//fmes = k.substring(5,7);
	//fdia = k.substring(8,10);
	fCon = k;    //fdia+'/'+fmes+'/'+fanio;
	//alert('...'+k+'.......'+fdia+'/'+fmes+'/'+fanio+'...');

	eval('document.form_0.fecha').value = fCon;

if(fProc == "")
msg += ' la fecha , Verifique .....';
if(msg == '')
{
 if(hasDBData('<%=request.getContextPath()%>','tbl_pla_aumento_cc',' compania='+<%=compania%>+' and actualizado =  \''+codigo+'\' and fecha_aumento = \''+fProc+'\'  ',''))
     {
			eval('document.form_0.go').disabled = true;
			eval('document.form_0.gover').disabled = false;
			eval('document.form_0.goeli').disabled = false;
			eval('document.form_0.goact').disabled = false;
	 		} else
      {
			eval('document.form_0.go').disabled = true;
			eval('document.form_0.gover').disabled = false;
			eval('document.form_0.goeli').disabled = true;
			eval('document.form_0.goact').disabled = true;
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
<%=fb.hidden("usuario",usuario)%>



  <tr class="TextHeader">
      <td align="center">
        PROCESO DE GENERACION DE AUMENTOS
		<br> Ver Aumentos Anteriores &nbsp;
		        <%=fb.select(ConMgr.getConnection(),"select distinct to_char(fecha_aumento,'dd/mm/yyyy') fechaCon, to_char(fecha_aumento,'dd/mm/yyyy') descAum from tbl_pla_aumento_cc where compania ="+compania+" and tipo_aumento = 1 order by 1 desc","fechaCon","",false,false,0,"",null,"onChange=\"javascript:refreshFecha(this.value)\"","Lista de Aumentos Anteriores","S")%>
				</td>
    </tr>

   <tr class="TextRow01">
      <td align="center">
       	<br> Fecha de Aumento:&nbsp;&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="fecha" />
							<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
							<jsp:param name="format" value="dd/mm/yyyy" />
							<jsp:param name="onChange" value="javascript:verAum();" />
							<jsp:param name="jsEvent" value="javascript:verAum();"/>
							</jsp:include>
				 <br> <authtype type='50'><%=fb.button("go","GENERAR Aumento General por C.Colectiva",false,false,"",null,"onClick=\"javascript:cargaAum()\"")%><authtype>
		  </td>
    </tr>


	 <tr class="TextRow02">
      <td align="center">
         <authtype type='51'><%=fb.button("gover","VER  Detalle de Aumentos",false,viewMode,"",null,"onClick=\"javascript:detalle()\"")%></authtype>
		  </td>
    </tr>

	 <tr class="TextRow01">
      <td align="center">
     <authtype type='52'><%=fb.button("goeli","ELIMINAR Aumentos",false,viewMode,"",null,"onClick=\"javascript:elimina()\"")%></authtype>
		</td>
    </tr>

	 <tr class="TextRow02">
      <td align="center">
     <authtype type='53'><%=fb.button("goact","ACTUALIZAR Aumentos",false,viewMode,"",null,"onClick=\"javascript:actualiza()\"")%></authtype>

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


String saveOption 	= request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction 		= request.getParameter("baction");
int keySize			= Integer.parseInt(request.getParameter("extraSize"));
String itemRemoved 	= "";
			empId 	= request.getParameter("empId");
ArrayList list = new ArrayList();
	if(tab.equals("0"))
	{
	int size=0;

	}//End Tab

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
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_aumento.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_aumento.jsp")%>';

	window.close();
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_aumento.jsp';
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

	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_aumento.jsp';

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
