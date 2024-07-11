
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="calen" scope="session" class="java.util.Hashtable"/>
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject cal = new CommonDataObject();
String sql="";
String ii="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String change= request.getParameter("change");
String date="";
String anio="";
String mes = "";
String compania = (String) session.getAttribute("_companyId"); 
String tipo = "";
double count = 0;
String userName = UserDet.getUserName();
String userId   = UserDet.getUserId();
boolean viewMode = false;
int callastLineNo =0;
int ind=0;
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
date = CmnMgr.getCurrentDate("dd/mm/yyyy");
anio = CmnMgr.getCurrentDate("yyyy");
mes = CmnMgr.getCurrentDate("mm");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		
		id = "0";
		cdo.addColValue("code","0");
		cdo.addColValue("date",date);
		cdo.addColValue("fechaPro",date);
		cdo.addColValue("usuario",userName);
		cdo.addColValue("anio",anio);
		
	}
	
	else
	{
		if (id == null) throw new Exception("El Acreedor del Empleado no es válido. Por favor intente nuevamente!");

sql = "select a.anio,a.cod_reporte, a.mes, a.partida, b.nombre, to_char(a.fecha_proceso,'dd/mm/yyyy') , a.anio||' - '||a.cod_reporte as descPla from tbl_pla_reporte_encabezado a,tbl_pla_reporte b where  a.cod_reporte = b.cod_reporte  and a.cod_compania = "+(String) session.getAttribute("_companyId")+"  and b.cod_reporte = "+id;
	cdo = SQLMgr.getData(sql);
	}
%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Cálculo de Planilla Preelaborada - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Cálculo de Planilla Preelaborada - Edición - "+document.title;
<%}%>


function setBAction(fName,actionValue)
{

  document.formCal.procesoq.value = actionValue;
}



function mouseOut(obj,option)
{
  var optDescObj=document.getElementById('optDesc');
  setoutc(obj,'ImageBorder');
  optDescObj.innerHTML='&nbsp;';
}

function doRedirect(k)
{
var msg = '';

var anio    = eval('document.formCal.anio').value ;
var codpla  = eval('document.formCal.tipoPla').value ;
var fProc   = eval('document.formCal.fechaProceso').value ;
var mes 	  = eval('document.formCal.mes').value ;
var fechatini = eval('document.formCal.fechaCrea').value ;
var partida = eval('document.formCal.partida').value ;
var fechatfin = '' ;

var user   = eval('document.formCal.userCrea').value ;

var ret = 0;
var proceso = 'Add' ;

if(anio == "")
msg = ' Año ';
if(codpla == "")
msg = ' Codigo ';
if(mes == "")
msg += ', Mes ';

if(fProc == "") 
msg += 'fecha ';
if(msg == '')
{

 if(confirm('Se Procesará la Preelaborada'))
 	{
	if(executeDB('<%=request.getContextPath()%>','call sp_pla_crea_encab_preelab(<%=compania%>,'+codpla+','+anio+','+mes+',\''+fProc+'\',\''+fechatini+'\',\''+user+'\')'))
		{
		
		var y=getDBData('<%=request.getContextPath()%>','SP_PLA_VERIFICAR_PREELAB(<%=compania%>,'+anio+','+codpla+','+mes+')','dual','','');	
    	if (y== 0)			
		{
	 		if(executeDB('<%=request.getContextPath()%>','call sp_pla_calculo_preelaborada(<%=compania%>,'+anio+','+codpla+','+mes+')'))
			    {
					alert('El Proceso de la Preelaborada se generó Satisfactoriamente!');	
					window.opener.location = '<%=request.getContextPath()%>/rhplanilla/calculo_planilla_preelab_list.jsp';
					window.close();
				}	 else 
				{
					ret =1;
					alert('No se ha generado la Preelaborada **** Consulte al Administrador!||<%=compania%>||'+anio+'||'+codpla+'||'+numpla+'||'+daanio+'||'+dacodpla+'||'+danumpla+'');
				}
		} else alert('La Preelaborada ya Existe...Verifique.. !');  //y
		} else alert('No se creo encabezado para esta planilla .. ó .. La Planilla existe.... Revisar...!');
	}  //confirm

} //msg
else alert('Seleccione '+msg);
if (ret != 0)
{
 executeDB('<%=request.getContextPath()%>','call sp_pla_elimina_encab('+codpla+',<%=compania%>,'+numpla+','+anio+')')
} 
}

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CALCULO DE PLANILLA PREELABORADA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	  <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		
	<%fb = new FormBean("formCal",request.getContextPath()+"/common/urlRedirect.jsp");%>
	
	<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%> <%=fb.hidden("id",id)%> <%=fb.hidden("cot",cdo.getColValue("cot"))%> <%=fb.hidden("code",cdo.getColValue("code"))%> <%=fb.hidden("alterno",cdo.getColValue("alterno"))%><%=fb.hidden("date",date)%><%fb.hidden("usuario",(String) session.getAttribute("_userName"));%><%fb.hidden("date",request.getParameter("date"));%>
          <td colspan="6">&nbsp;</td>
        </tr>
		

			 <tr class="TextHeader" align="left">
          <td colspan="6">&nbsp;Encabezado de Planilla</td>
        </tr>
        <tr class="TextRow01">
          <td>&nbsp;Año </td>
          <td colspan="2"><%=fb.textBox("anio",cdo.getColValue("anio"),true,false,false,5)%></td>
		   <td colspan="3"> Tipo de Planilla <%=fb.select(ConMgr.getConnection(),"select cod_reporte as codpla, nombre, cod_reporte from tbl_pla_reporte ","tipoPla","",false,false,0,"Text10",null,null,null,"4")%></td>
		    </tr>
				
				
        <tr class="TextRow01" >
          <td>&nbsp;Mes</td>
          <td><%=fb.select("mes","1=ENERO,2=FEBRERO,3=MARZO,4=ABRIL,5=MAYO,6=JUNIO,7=JULIO,8=AGOSTO,9=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,"Text10",null,null,"","")%></td>
          <td>Fecha de Proceso</td>
         <td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fechaProceso"/>	
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fechaProceso")==null)?"":cdo.getColValue("fechaProceso")%>" />
				</jsp:include>
				</td>
          <td>Partida de Décimo</td>
          <td> <%=fb.select("partida","1=PRIMERA,2=SEGUNDA,3=TERCERA",cdo.getColValue("partida"),false,true,0,"Text10",null,null,"","S")%></td>
		         
        </tr>
      

	       <tr class="TextRow02">
          <td colspan="6">&nbsp;</td>
        </tr>
       
	     <tr class="TextHeader" align="left">
          <td colspan="6">&nbsp;Bitàcora</td>
        </tr>
        <tr class="TextRow01">
		  <td>&nbsp;</td>
          <td colspan="2">&nbsp;Fecha de Creaciòn: </td>
          <td><%=fb.textBox("fechaCrea",date,true,false,true,10,10)%></td>
          <td>&nbsp;Creado por:</td>
          <td><%=fb.textBox("userCrea",userName,true,false,true,10,10)%></td>
             
		</tr>
        <tr class="TextRow01">
		  <td>&nbsp;</td>
          <td colspan="2">&nbsp;Fecha de Modificaciòn:</td>
          <td><%=fb.textBox("fechaMod",date,true,false,true,10,10)%></td>
          <td>&nbsp;Modificado por:</td>
          <td><%=fb.textBox("userMod",userName,true,false,true,10,10)%></td>
         
		</tr>
        <tr class="TextRow02">
          <td colspan="6" align="right"><%=fb.button("procesar","Procesar",true,false,null,null,"onClick=\"javascript:doRedirect('3')\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
		
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
	</tr>
</table>		

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET 
else
{
  cdo = new CommonDataObject();
  cdo.setTableName("tbl_pla_reporte_encabezado");

  cdo.addColValue("anio", request.getParameter("anio")); 
  cdo.addColValue("cod_reporte",request.getParameter("tipoPla"));
  cdo.addColValue("mes",request.getParameter("mes"));
  cdo.addColValue("fecha_proceso",request.getParameter("fechaIni"));
  cdo.addColValue("partida",request.getParameter("partida"));
 
 
  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 
	cdo.addColValue("fecha_mod",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("usuario_mod",(String) session.getAttribute("_userName")); 
	
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and cod_reporte="+request.getParameter("tipoPla")+" and mes = "+mes);

	SQLMgr.update(cdo);
  }
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/calculo_planilla_preelab_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/calculo_planilla_preelab_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/calculo_planilla_preelab_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
