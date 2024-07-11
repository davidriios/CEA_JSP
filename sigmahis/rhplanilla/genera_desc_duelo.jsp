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
<jsp:useBean id="htajus" scope="session" class="java.util.Hashtable" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList aj = new ArrayList();
ArrayList al = new ArrayList();
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
String cia = (String) session.getAttribute("_companyId"); 
String empId = request.getParameter("empid");
String trxId = request.getParameter("trx");
String tipoId = request.getParameter("tipo");

String fecha="",fechaIngreso="";
int benLastLineNo = 0, prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anioC = CmnMgr.getCurrentDate("yyyy");
String mes = CmnMgr.getCurrentDate("mm");
String dia = CmnMgr.getCurrentDate("dd");
String userName = UserDet.getUserName();
int per = 0;
double total = 0.00;
int iconHeight = 48;
int iconWidth = 48;
int ajusLastLineNo = 0;

//if(request.getParameter("extraLastLineNo")!=null && ! request.getParameter("extraLastLineNo").equals(""))
//extraLastLineNo=Integer.parseInt(request.getParameter("extraLastLineNo"));
//else extraLastLineNo=0;

int day = Integer.parseInt(CmnMgr.getCurrentDate("dd"));
int mont = Integer.parseInt(CmnMgr.getCurrentDate("mm"));
if (tab == null) tab = "0";


if(day >16) per = mont*2;
else per =  mont*2-1;

	if (anio == null) anio = anioC;	
	if (periodo == null) periodo = ""+per;
	if (planilla == null) planilla = "1";
	if (mode == null) mode = "view";
		
if (request.getMethod().equalsIgnoreCase("GET"))
{
   if (mode.equalsIgnoreCase("view"))
	{
		if (anio == null) throw new Exception("El Año no es válido. Por favor intente nuevamente!");
		if (periodo == null) throw new Exception("El Periodo no es válido. Por favor intente nuevamente!");
	    if (planilla == null) throw new Exception("El Código de Planilla no es válido. Por favor intente nuevamente!");
	
	htajus.clear();	
		sql="select distinct(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania,  a.nombre_empleado as nombre, a.num_empleado as numEmpleado, a.pariente, a.nombre_pariente, a.descripcion, to_char(a.fecha_fallecimiento,'dd/mm/yyyy') as fecha from tbl_pla_descto_duelo_pend a where a.compania="+(String) session.getAttribute("_companyId")+appendFilter;
		
		aj=SQLMgr.getDataList(sql);
		System.out.println("ajuste size="+aj.size());
		ajusLastLineNo= aj.size();
		for(int i=1; i<=aj.size(); i++)
		{
		CommonDataObject cdo3 = (CommonDataObject) aj.get(i-1);
		if(i<10)  key = "00"+i;
		else if(i<100)
		key = "0"+i;
		else  
		key= ""+i;
		cdo3.addColValue("key",key);
		try {
		htajus.put(key,cdo3);
		
		}//End Try
		catch (Exception e)
		{
		System.err.println(e.getMessage());
		}//End Catch
		}//End for
	}
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

function genera()
{
var msg = '';
var fAcr     =  document.form_0.acrCode.value;
var fGrp     =  document.form_0.grpCode.value;
var p_user   =  document.form_0.usuario.value; 
var period   =  document.form_0.periodo.value; 
var anio   =  document.form_0.anio.value; 
var cont   	 =  document.form3.cont.value; 
var size     = eval('document.form_0.ajusSize').value;
var count    = 0;

if(fAcr == "") 
msg += ' un Acreedor , Verifique .....';
if(fGrp == "") 
msg += ' un Grupo , Verifique .....';
if(cont <= 0) 
msg += ' una Transacción para aplicar el descuento ..';

if(msg == '')
	{
 		if(confirm('Se Generará el Descuento por Duelo de Pariente .... Desea Continuar...'))
		{

     for(i=0;i<size;i++)
			{
				if (eval('document.form3.check'+i).checked)
				{
   				var monto 	= eval('document.form3.cuota'+i).value;
					var prov 		= eval('document.form3.provincia'+i).value;
					var sigla 	= eval('document.form3.sigla'+i).value;
					var tomo 		= eval('document.form3.tomo'+i).value;
					var asiento = eval('document.form3.asiento'+i).value;
					var pariente = eval('document.form3.pariente'+i).value;
					
					if(executeDB('<%=request.getContextPath()%>','call sp_pla_descuento_sind(\''+monto+'\',<%=cia%>,'+fAcr+','+fGrp+',\''+p_user+'\')'))
					 {
					if(executeDB('<%=request.getContextPath()%>','UPDATE tbl_pla_pariente_muerte SET ESTADO_DESCTO = \'PA\', FECHA_DES =  sysdate , ANIO_DES = \''+anio+'\', QUINCENA_DES = \''+period+'\' WHERE provincia = \''+prov+'\' and sigla = \''+sigla+'\' AND tomo =\''+tomo+'\' AND asiento = \''+asiento+'\' and pariente = \''+pariente+'\' and compania = <%=(String) session.getAttribute("_companyId")%>','tbl_pla_pariente_muerte'))
			     count++;
				
					} else alert('No se ha podido generar los Descuento...Consulte al Administrador!');
				}
				
				alert('Descuentos por Cuota de Sindicato Generados ... Satisfactoriamente!');	
		window.location = '<%=request.getContextPath()%>/rhplanilla/genera_desc_duelo.jsp?mode=view';
			}
		}
	} 
else alert('Seleccione '+msg);
}
function doAction()
{
	verCheck();
}


function verCheck()
{
var size = eval('document.form3.ajusSize').value;
var tb = eval('document.form3.tab').value;
var totalCheck = 0;

if((tb==3)&&(size>0))
{
for (i=0;i<parseInt(size);i++)
	{
		if (eval('document.form3.check'+i).checked)
	  	{
			totalCheck += 1;
			document.getElementById("cuota"+i).value='2.00';
			}
	}
	document.getElementById("cont").value=totalCheck;
}
}
	
function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}

function acreedor()
{
abrir_ventana('../common/search_acreedor.jsp?fp=duelo');
}

function grupo()
{
abrir_ventana('../common/search_grupo_descuento.jsp?fp=duelo');
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
			<%=fb.hidden("ajusSize",""+htajus.size())%>	
			<%=fb.hidden("usuario",userName)%>	
			<%=fb.hidden("periodo",periodo)%>
			<%=fb.hidden("anio",anio)%>		

			<tr class="TextHeader">
			  <td colspan="10" align="center">
				GENERA DESCUENTO POR DUELO 
				</td>
			</tr>
			
			<tr class="TextHeader">
			  <td colspan="5" align="center">
			  Acreedor 
				</td>
				 <td colspan="5" align="center">
				Tipo de Descuento
				</td>
			</tr>
			
				<tr class="TextHeader">
			  <td colspan="5" align="left">
			 				<%=fb.intBox("acrCode","",false,false,true,5,4)%> 
						  <%=fb.textBox("acrDesc","",false,false,true,35)%> 
						  <%=fb.button("btnacr","Ir",false,false,null,null,"onClick=\"javascript:acreedor()\"")%>
					</td>
			 <td colspan="5" align="left">
				 <%=fb.intBox("grpCode","14",false,false,true,5,4)%> 
						  <%=fb.textBox("grpDesc","AYUDA MORTUARIA",false,false,true,35)%> 
						  <%=fb.button("btngrp","Ir",true,false,null,null,"onClick=\"javascript:grupo()\"")%>
				</td>
			</tr>
			
			<tr class="TextRow02">
			  <td colspan="10" align="right">
				Reporte de Ajustes :
				 &nbsp; <%=fb.button("reporte","Reporte",true,false,null,null,"onClick=\"javascript:window.print()\"")%> 			 &nbsp;&nbsp;&nbsp;
				Generar Descuentos por Duelo a Los Empleados : &nbsp; <%=fb.button("actualiza","...Generar...",true,false,null,null,"onClick=\"javascript:window.genera()\"")%> </td>
		    </tr>
			
			
			<%=fb.formEnd(true)%>
		 </table>
 		 </td>
	</tr>

	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
			<tr>
				<td>

<!-- MAIN DIV START HERE -->

<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================   F O R M   S T A R T   H E R E  ============== -->
<!-- ================		tab(3)  autoriza ajustes   ============== -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","3")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("ajusSize",""+htajus.size())%>
	
	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>

	<tr>
		<td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer" >
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel" onClick="javascript:verCheck()">
					<td width="95%">&nbsp;Selección</td>
					<td width="5%"><%=fb.checkbox("check3","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+aj.size()+",this)\"","Seleccionar todos los Ajustes. !")%></td>
				</tr>
			</table>
		</td>
	</tr>
	
	<tr id="panel4">
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
				<tr class="TextHeader" align="center">
					<td width="15%">Cédula</td>
					<td width="10%">No. Empleado</td>
					<td width="25%">Nombre del Empleado</td>
					<td width="10%">Parentesco</td>
					<td width="15%">Nombre del Pariente</td>
					<td width="10%">Fecha de Nacimiento</td>
					<td width="5%">&nbsp;</td>
					<td width="10%">Monto a Decontar</td>
				
				</tr>
 				 <%  
							al=CmnMgr.reverseRecords(htajus);	
							for(int i=0; i<htajus.size(); i++)
							{
							key = al.get(i).toString();	
							CommonDataObject cdo3 = (CommonDataObject) htajus.get(key);
							String color = "TextRow01";
							if (i % 2 == 0) color = "TextRow02";
				%>		
			
				<%=fb.hidden("key"+i,cdo3.getColValue("key"))%> 
				<%=fb.hidden("empIdAj"+i,cdo3.getColValue("empId"))%> 
				<%=fb.hidden("fechaAj"+i,cdo3.getColValue("fecha"))%> 
				<%=fb.hidden("secuencia"+i,cdo3.getColValue("codigo"))%> 
				<%=fb.hidden("chequeCreado"+i,cdo3.getColValue("imprimir"))%> 
				<%=fb.hidden("numero"+i,cdo3.getColValue("num_planilla"))%>
				<%=fb.hidden("anio"+i,cdo3.getColValue("anio"))%>
				<%=fb.hidden("planilla"+i,cdo3.getColValue("cod_planilla"))%>
				<%=fb.hidden("provincia"+i,cdo3.getColValue("provincia"))%> 
				<%=fb.hidden("sigla"+i,cdo3.getColValue("sigla"))%> 
				<%=fb.hidden("tomo"+i,cdo3.getColValue("tomo"))%> 
				<%=fb.hidden("asiento"+i,cdo3.getColValue("asiento"))%> 
				<%=fb.hidden("numEmpl"+i,cdo3.getColValue("numEmpleado"))%> 
				<%=fb.hidden("pariente"+i,cdo3.getColValue("pariente"))%> 
				<%=fb.hidden("remove"+i,"")%>
									
				<tr class="TextRow01">
				<td><%=cdo3.getColValue("cedula")%></td>
					<td><%=cdo3.getColValue("numEmpleado")%></td>
					<td><%=cdo3.getColValue("nombre")%></td>
					<td align="left"><%=cdo3.getColValue("descripcion")%></td>
					<td align="left"><%=cdo3.getColValue("nombre_pariente")%></td>
					<td align="center"><%=cdo3.getColValue("fecha")%></td>
					<td align="center"><%=fb.checkbox("check"+i,"S",false,false,null,null,"onClick=\"javascript:verCheck()\"")%></td>
					<td align="right"><%=fb.textBox("cuota"+i,"",false,false,false,4)%></td>
					
				</tr>		
				<%
				}
				%>
			</table>
		</td>
	</tr>
 	 
	<tr class="TextRow01">
      <td align="right">Total por Descontar : <%=fb.textBox("cant",""+htajus.size(),false,false,true,4)%> &nbsp;&nbsp;Total de Decuentos Seleccionados : <%=fb.textBox("cont","",false,false,true,4)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
	  <% fb.appendJsValidation("if(error>0)doAction();"); %>	
		 
	<tr class="TextRow02">
          <td align="right">
            Opciones de Guardar:
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
            <%=fb.radio("saveOption","C",false,false,false)%>Cerrar
           
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
<%=fb.formEnd(true)%>

<!-- =================  F O R M   E N D   H E R E   =============== -->
</table>
<script type="text/javascript">
<%
String tabLabel = "'Sobretiempo','Ausencias y Tardanzas','Descuentos,Ajuste y Otras Trx', 'Autorización Planilla de Ajustes'";
if (!mode.equalsIgnoreCase("add"))
{
}
%>
</script>

			</td>
		  </tr>
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
int keyAjSize		= Integer.parseInt(request.getParameter("ajusSize"));
String itemRemoved 	= "";
	   empId 	= request.getParameter("empId");
System.out.println("keySize = \n"+keyAjSize);
	
   for(int a=0; a<keyAjSize; a++)
		{ 
		CommonDataObject cdo = new CommonDataObject();
	
			String 	codigoAj = request.getParameter("secuencia"+a);
			empId = request.getParameter("empIdAj"+a); 
			String fechaAj = request.getParameter("fechaAj"+a); 
	
	cdo.setTableName("tbl_pla_pago_ajuste");
	
	cdo.addColValue("secuencia",request.getParameter("secuencia"+a));
	
	
		if (request.getParameter("check"+a) != null && request.getParameter("check"+a).equalsIgnoreCase("S"))
		
		{
		cdo.addColValue("vobo_estado","S");
		cdo.addColValue("vobo_usuario",(String) session.getAttribute("_userName")); 
		cdo.addColValue("vobo_fecha",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")); 
		
		} 
		cdo.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and fecha_cheque = '"+fechaAj+"' and secuencia = "+codigoAj+" and emp_id="+empId);
 
		SQLMgr.update(cdo);
		
  		}//End For
 
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
  if (tab.equals("0") || tab.equals("1") || tab.equals("2") || tab.equals("3"))
  {
    if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/genera_desc_duelo.jsp"))
    {
%>
  window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/genera_desc_duelo.jsp")%>';
<%
    }
    else
    {
%>
  window.opener.location = '<%=request.getContextPath()%>/rhplanilla/genera_desc_duelo.jsp?mode=view';
<%
    }
  }

 if (saveOption.equalsIgnoreCase("O"))
  {
%>
    setTimeout('editMode()',500);
<%
  }
  else if (saveOption.equalsIgnoreCase("C"))
  {
%>
  window.close();
<%
  }
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
  window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view';
}


</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

