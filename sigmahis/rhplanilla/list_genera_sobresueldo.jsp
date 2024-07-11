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

if(day >16)
		per	= 16;
		
else per =  15;

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
 if(hasDBData('<%=request.getContextPath()%>','tbl_pla_aumento_cc',' compania='+<%=compania%>+' and actualizado =  \''+codigo+'\' and fecha_aumento = \''+fProc+'\'  ',''))
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

function genera()
{
var msg = '';
var fanio = '';
var	fmes = '';
var	fdia = '';
var	fCon = '';
var anio    	=  document.form_0.anio.value;
var p_user  	=  document.form_0.usuario.value; 
var anioAct   =  eval(document.form_0.anioAct).value  ;
var codigo = 'N';
anioAct ++ ;
if(anio == "") 
{
	fProc = '31/12/'+anioAct;
	eval('document.form_0.fecha').value = fProc;
}
if(msg == '')
{
	if(confirm('Se Generará el Aumento por Sobresueldo .... Desea Continuar...'))
	{

		if(executeDB('<%=request.getContextPath()%>','call sp_pla_generar_sobresueldo(<%=compania%>,\''+fProc+'\',\''+p_user+'\')'))
		{
		alert('Aumentos por Sobresueldo Generados ... Satisfactoriamente!');	
		
			eval('document.form_0.go').disabled = true;
			eval('document.form_0.gover').disabled = false;
			eval('document.form_0.goeli').disabled = false;
			eval('document.form_0.goact').disabled = false;
		
		
			
		} else alert('No se ha podido generar los Aumentos...Consulte al Administrador!');
	
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

if(confirm('Está seguro que desea Eliminar los Aumento por Sobresueldo para esta Fecha.... Desea Continuar...'))
	{
   if(executeDB('<%=request.getContextPath()%>','delete from tbl_pla_aumento_cc where compania = <%=compania%> and actualizado = \''+codigo+'\' and tipo_aumento = 5 and  fecha = \''+fProc+'\'','tbl_pla_aumento_cc'))
		{
		alert('Aumentos por Sobresueldos Eliminados ... Satisfactoriamente!');	
		eval('document.form_0.go').disabled = false;
			eval('document.form_0.gover').disabled = true;
			eval('document.form_0.goeli').disabled = true;
			eval('document.form_0.goact').disabled = true;
			
			window.opener = '<%=request.getContextPath()%>/rhplanilla/list_genera_sobresueldo.jsp';
		
    }  else alert('No se ha podido eliminar los Aumentos...Consulte al Administrador!');
}  else alert('Cancelado por el usuario la eliminación de los Aumentos...!');
}

function detalle()
{

var fechaDet=document.form_0.fecha.value;
abrir_ventana('../rhplanilla/pago_sobresueldo_list.jsp?fp=sobresueldo&fecha='+fechaDet);
}

function detalleAct()
{

var fechaDet=document.form_0.fechaAct.value;
var anio=document.form_0.anioA.value;
var mes=document.form_0.mesAct.value;
abrir_ventana('../rhplanilla/pago_sobresueldo_list.jsp?fp=actualiza&fecha='+fechaDet+'&mes='+mes+'&anio='+anio);
}

function actualiza()
{
var msg = '';
var codigo = 'N';
var fProc    =  document.form_0.fecha.value;
var p_user   =  document.form_0.usuario.value; 
if(confirm('Está seguro que desea Actualizar los Aumento por Convención Colectiva para esta Fecha.... Desea Continuar...'))
	{
  if(executeDB('<%=request.getContextPath()%>','call sp_pla_actualizar_aumentos(<%=compania%>,\''+fProc+'\',\''+p_user+'\')'))
		{
		alert('Aumentos por Convención Colectiva Actualizados ... Satisfactoriamente!');	
		  eval('document.form_0.go').disabled    = true;
			eval('document.form_0.gover').disabled = true;
			eval('document.form_0.goeli').disabled = true;
			eval('document.form_0.goact').disabled = true;
			window.opener = '<%=request.getContextPath()%>/rhplanilla/list_aumento.jsp';
		
    }  else alert('No se ha podido actualizar los Aumentos...Consulte al Administrador!');
	}  else alert('Cancelado por el usuario la actualización de los Aumentos...!');
}


function refreshFecha(k)
{
var msg = '';
var fanio = '';
var fmes = '';
var fdia = '';
var fCon    =  document.form_0.fechaCon.value;
var fProc    =  document.form_0.fechaCon.value;
var p_user   =  document.form_0.usuario.value; 
var codigo = 'N';
       
	
	fanio = k.substring(0,4);
	fmes = k.substring(5,7);
	fdia = k.substring(8,10);
	fCon = fdia+'/'+fmes+'/'+fanio;
///alert('...'+k+'.......'+fdia+'/'+fmes+'/'+fanio+'...');

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

function fechaCk(k)
{
var msg = '';
var anio = document.form_0.anio.value;
//if (anio != null)
	document.form_0.fecha.value='31/12/'+k;
	
	 if(hasDBData('<%=request.getContextPath()%>','tbl_pla_aumento_cc',' compania='+<%=compania%>+' and tipo_aumento = 5 and to_char(fecha, \'rrrr\') = \''+k+'\'  ',''))
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
}


function ckFecha(k)
{
var msg = '';
var anio = document.form_0.anioA.value;
var per = document.form_0.periodo.value;
 if (per >= 16) document.form_0.fechaAct.value='31/'+k+'/'+anio;


	//document.form_0.fechaAct.value= '31/03/2011';
	
	 if(hasDBData('<%=request.getContextPath()%>','tbl_pla_aumento_cc',' compania='+<%=compania%>+' and mes =   \''+k+'\' and tipo_aumento = 5 and to_char(fecha_aumento, \'rrrr\') = \''+anio+'\'  ',''))
     {
			eval('document.form_0.go').disabled = true;
			eval('document.form_0.gover').disabled = true;
			eval('document.form_0.goeli').disabled = true;
			eval('document.form_0.goact').disabled = false;
			eval('document.form_0.goverAct').disabled = false;
	 		} else
      {
			eval('document.form_0.go').disabled = false;
			eval('document.form_0.gover').disabled = true;
			eval('document.form_0.goeli').disabled = true;
			eval('document.form_0.goact').disabled = true;
			eval('document.form_0.goverAct').disabled = true;
			}
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
<%=fb.hidden("anioAct",anio)%>
<%=fb.hidden("periodo",periodo)%>


  <tr class="TextHeader">
      <td align="center">
        PROCESO DE GENERACION DE SOBRESUELDOS
				<br> &nbsp;
		  </td>
    </tr>
		
		 <tr class="TextHeader">
      <td align="center">
       Año del Sobresueldo: <%=fb.textBox("anio","",false,false,false,4,"Text10",null,"onChange=\"javascript:fechaCk(this.value)\"")%>	<%=fb.textBox("fecha","",false,false,true,10)%>
			 	 
			</td>
    </tr>
		
  <tr class="TextRow01">
      <td align="center">&nbsp;
       
	  </td>
    </tr>
	
	 <tr class="TextHeader">
      <td align="center">
         <%=fb.button("go","Generar Aumento por Sobresueldo",false,false,"Text10",null,"onClick=\"javascript:genera()\"")%>
								 
		  </td>
    </tr>
 
	
	 <tr class="TextRow01">
      <td align="center">&nbsp;
       
	  </td>
    </tr>
	
	 <tr class="TextHeader">
      <td align="center">
         <%=fb.button("gover","Ver Detalle del Sobresueldo",false,viewMode,"Text10",null,"onClick=\"javascript:detalle()\"")%>
								 
		  </td>
    </tr>
		
	 <tr class="TextRow01">
      <td align="center">&nbsp;
       
		  </td>
    </tr>
	
	 <tr class="TextHeader">
      <td align="center">
     <%=fb.button("goeli","Eliminar Sobresueldos a Empleados",false,viewMode,"Text10",null,"onClick=\"javascript:elimina()\"")%>
		</td>
    </tr>
		
		 <tr class="TextRow01">
      <td align="center">&nbsp;
       
	  </td>
    </tr>
		
		 <tr class="TextHeader">
      <td align="center">
        PROCESO PARA ACTUALIZAR LOS SOBRESUELDOS
				<br> &nbsp;
		  </td>
    </tr>
	
		 <tr class="TextHeader">
      <td align="center">
       Año del Sobresueldo: <%=fb.textBox("anioA","",false,false,false,4,"Text10",null,"")%>	
			 Mes : <%=fb.select("mesAct","01=ENERO, 02=FEBRERO,03=MARZO, 04=ABRIL, 05=MATO, 06=JUNIO,07=JULIO,08=AGOSTO, 09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE, 12=DICIEMBRE","",false,false,0,null,null,"onChange=\"javascript:ckFecha(this.value)\"",null,"T")%> Hasta el : <%=fb.textBox("fechaAct","",false,false,false,10)%>
			 	 
			</td>
    </tr>
		
		 <tr class="TextRow01">
      <td align="center">&nbsp;
       
	  </td>
    </tr>
	
	 <tr class="TextHeader">
      <td align="center">
         <%=fb.button("goverAct","Ver Detalle del Sobresueldo",false,viewMode,"Text10",null,"onClick=\"javascript:detalleAct()\"")%>
								 
		  </td>
    </tr>
		
	 <tr class="TextRow01">
      <td align="center">&nbsp;
       
		  </td>
    </tr>
			
		
	 <tr class="TextHeader">
      <td align="center">
     <%=fb.button("goact","Actualizar Aumentos",false,viewMode,"Text10",null,"onClick=\"javascript:actualiza()\"")%>
		 
		</td>
    </tr>
		
			 <tr class="TextRow01">
      <td align="center">&nbsp;
       
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
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_genera_sobresueldo.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_genera_sobresueldo.jsp")%>';
	
	window.close();
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_genera_sobresueldo.jsp';
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

	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_genera_sobresueldo.jsp';

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
