<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="iTrx" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vTrx" scope="session" class="java.util.Vector" />
<jsp:useBean id="iEstado" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vEstado" scope="session" class="java.util.Vector" />

<%
/**
================================================================================


================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
ArrayList alEstado = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String tab=request.getParameter("tab");
String change = request.getParameter("change");
String key="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

boolean viewMode = false;
int lastLineNo =0;
if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
			alEstado = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion/*||' - '||codigo*/ as optLabelColumn, codigo as optTitleColumn from tbl_pla_estado_emp order by descripcion",CommonDataObject.class);

	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		iTrx.clear();
		vTrx.clear();
		iEstado.clear();
		vEstado.clear();
	}
	else
	{
		if (id == null) throw new Exception("Registro de Planillas  no es válido. Por favor intente nuevamente!");

		sql = "select a.cod_planilla, a.compania , a.nombre, a.beneficiarios , a.tipopla as codetipo, a.cod_obj as codemensual, a.cod_concepto as codeconcepto, a.tipo_emp as tipoempleado, a.cod_reporte as codeEstado, b.cod_concepto as codconcept, b.descripcion as concepto, c.codigo as codeemplea, c.descripcion as  empleado, d.tipopla as codplanilla, d.descripcion as planilla, e.codigo as codeestado, e.descripcion as estados, f.cod_reporte as codereporte, f.nombre as mensual,nvl(a.is_visible,'N')is_visible,nvl(a.genera_asiento,'N') as genera_asiento ,nvl(a.genera_orden,'N') as genera_orden from tbl_pla_planilla a, tbl_pla_planilla_concepto b, tbl_pla_tipo_empleado c, tbl_pla_tipo_planilla d, tbl_pla_estado_emp e, tbl_pla_reporte f where a.cod_obj=f.cod_reporte(+) and a.cod_concepto=b.cod_concepto and a.tipo_emp=c.codigo(+) and a.tipopla=d.tipopla(+) and a.cod_reporte=e.codigo(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.cod_planilla="+id;
		cdo = SQLMgr.getData(sql);
		
		if (change == null)
		{
			iTrx.clear();
			vTrx.clear();
			iEstado.clear();
			vEstado.clear();
			/*sql = "select a.id, a.codigo_trx as codigo, (select descripcion from tbl_pla_tipo_transaccion where codigo=a.codigo_trx) as descripcion,estado from tbl_pla_trx_x_planilla a where a.cod_planilla="+id+" order by 2";
			al  = SQLMgr.getDataList(sql);
			lastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo1 = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo1.addColValue("key",key);

				try
				{
					iTrx.put(key, cdo1);
					vTrx.addElement(cdo1.getColValue("codigo_trx"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}*/
			sql = "select a.cod_estado,a.cod_planilla,a.compania,to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion,a.usuario_creacion from tbl_pla_estado_emp_planilla a where a.compania ="+(String) session.getAttribute("_companyId")+" and a.cod_planilla="+id+" order by 2";
			al  = SQLMgr.getDataList(sql);
			lastLineNo = al.size();
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo1 = (CommonDataObject) al.get(i);
				cdo1.setKey(i);
				cdo1.setAction("U");
				try
				{
					iEstado.put(cdo1.getKey(),cdo1);
					vEstado.addElement(cdo1.getColValue("cod_estado"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}
	}



%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp" %>
<%@ include file="../common/tab.jsp" %>

</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Registro de Planillas - "+document.title;
function conceptos (){abrir_ventana1('../rhplanilla/list_planilla_concepto.jsp?fp=registroPlanilla');}
function empleados (){abrir_ventana1('../rhplanilla/list_tipo_empleado.jsp?id=1');}
function planillas(){abrir_ventana1('../rhplanilla/list_planilla.jsp?id=1');}
function Mensuales (){abrir_ventana1('../rhplanilla/list_tipo_registro.jsp?id=1');}
function Estados(){abrir_ventana1('../rhplanilla/list_estado.jsp?id=1');
}
function checkEstado(k)
{

	var estadoNew = eval('document.form1.cod_estado'+k).value;
	for (c=0;c<<%=iEstado.size()%>;c++)
	{
		if(c!=k)
		{
			var estado = eval('document.form1.cod_estado'+c).value;
			if(estadoNew==estado){alert('El estado ya Existe seleccionado en el listado');eval('document.form1.cod_estado'+k).value='';break;}
		}
	}
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - REGISTRO DE PLANILLA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">
<tr>
			<td>
<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("tab","0")%>
			<%=fb.hidden("baction","")%>

			<tr>	
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="2">&nbsp;<cellbytelabel>Generales de la Planilla</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td width="25%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width="75%"><%=id%></td>
			</tr>
			<tr class="TextRow01" >
				<td>&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
				<td><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,50,60)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Concepto Planilla</cellbytelabel></td>
				<td><%=fb.intBox("codeconcepto",cdo.getColValue("codeconcepto"),true,false,true,15,2)%>
					<%=fb.textBox("concepto",cdo.getColValue("concepto"),false,false,true,45)%>
					<%=fb.button("btnconcepto","...",false,false,null,null,"onClick=\"javascript:conceptos()\"")%>
				</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Beneficiarios</cellbytelabel></td>
				<td><%=fb.select("beneficiarios","EM=EMPLEADO,AC=ACREEDORES,OP=OTROS PAGOS",cdo.getColValue("beneficiarios"))%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Tipo de Empleado</cellbytelabel></td>
				<td><%=fb.intBox("tipoempleado",cdo.getColValue("tipoempleado"),false,false,true,15,2)%>
					<%=fb.textBox("empleado",cdo.getColValue("empleado"),false,false,true,45)%>
					<%=fb.button("btempleado","...",false,false,null,null,"onClick=\"javascript:empleados()\"")%>
				</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Tipo de Planilla</cellbytelabel></td>
				<td><%=fb.intBox("codetipo",cdo.getColValue("codetipo"),true,false,true,15,2)%>
					<%=fb.textBox("planilla",cdo.getColValue("planilla"),false,false,true,45)%>
					<%=fb.button("btnplanilla","...",false,false,null,null,"onClick=\"javascript:planillas()\"")%>
				</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Planilla Mensual</cellbytelabel></td>
				<td><%=fb.intBox("codemensual",cdo.getColValue("codemensual"),false,false,true,15,3)%>
					<%=fb.textBox("mensual",cdo.getColValue("mensual"),false,false,true,45)%>
					<%=fb.button("btnmensual","...",false,false,null,null,"onClick=\"javascript:Mensuales()\"")%>
				</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Estados de los Empleados</cellbytelabel></td>
				<td><%=fb.intBox("codeEstado",cdo.getColValue("codeEstado"),false,false,true,15,2)%>
					<%=fb.textBox("estados",cdo.getColValue("estados"),false,false,true,45)%>
					<%=fb.button("btnestado","...",false,false,null,null,"onClick=\"javascript:Estados()\"")%>
				</td>
			</tr>
			<tr class="TextRow02">
				<td><cellbytelabel>Visible en Planilla de Empleado</cellbytelabel></td>
				<td><%=fb.select("is_visible","N=NO,S=SI",cdo.getColValue("is_visible"),false,false,0,"",null,null,null,"")%></td>
			</tr>
			<tr class="TextRow02">
				<td><cellbytelabel>Genera Pre - Asientos Automaticos?</cellbytelabel></td>
				<td><%=fb.select("genera_asiento","N=NO,S=SI",cdo.getColValue("genera_asiento"),false,false,0,"",null,null,null,"")%></td>
			</tr>
			<tr class="TextRow02">
				<td><cellbytelabel>Genera orden de Pago Automatica?</cellbytelabel></td>
				<td><%=fb.select("genera_orden","N=NO,S=SI",cdo.getColValue("genera_orden"),false,false,0,"",null,null,null,"")%></td>
			</tr>
			<tr class="TextRow02">
					<td align="right" colspan="2">
						Opciones de Guardar:
						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				 <%=fb.formEnd(true)%>


    </table>
<!-- TAB0 DIV END HERE-->
		</div>
		
		<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("eSize",""+iEstado.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Planilla</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right">C&oacute;digo</td>
							<td width="35%"><%=id%></td>
							<td width="15%" align="right">Nombre</td>
							<td width="35%"><%=cdo.getColValue("nombre")%></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Estado de Empleados</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" >
							<td width="80%">Estado</td>
							<td width="20%" align="center"><%=fb.submit("addEstado","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Estado")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iEstado);
for (int i=0; i<iEstado.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo1 = (CommonDataObject) iEstado.get(key);
%>
						<%=fb.hidden("action"+i,cdo1.getAction())%>
						<%=fb.hidden("key"+i,cdo1.getKey())%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("cod_estado_old"+i,""+cdo1.getColValue("cod_estado"))%>
						<%=fb.hidden("fecha_creacion"+i,cdo1.getColValue("fecha_creacion"))%>
						<%=fb.hidden("usuario_creacion"+i,cdo1.getColValue("usuario_creacion"))%>
						
					<%if(!cdo1.getAction().equalsIgnoreCase("D")){%>
					<tr class="TextRow01">
						<td><%=fb.select("cod_estado"+i,alEstado,cdo1.getColValue("cod_estado"),false,false,0,"Text10",null,null,"","S","onchange=\"checkEstado("+i+")\"")%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
					</tr>
<%}
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td colspan="4" align="right">
						Opciones de Guardar:
						<!--<%//=fb.radio("saveOption","N")%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C",false,false,false)%>Cerrar
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB1 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
String tabLabel = "'Datos Generales','Estado de Empleados'";
String tabInactivo ="";
if (mode.equalsIgnoreCase("add"))tabInactivo ="1";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','','','','',[<%=tabInactivo%>]);
</script>
</td>
</tr>
	
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
	String baction = request.getParameter("baction");
	
	if (tab.equals("0"))
	{

		cdo = new CommonDataObject();
		cdo.setTableName("tbl_pla_planilla");
		cdo.addColValue("fecha_mod",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		cdo.addColValue("usuario_mod",(String) session.getAttribute("_userName"));
		cdo.addColValue("nombre",request.getParameter("nombre"));
		cdo.addColValue("beneficiarios",request.getParameter("beneficiarios"));
		cdo.addColValue("tipopla",request.getParameter("codetipo"));
		cdo.addColValue("cod_obj",request.getParameter("codemensual"));
		cdo.addColValue("cod_concepto",request.getParameter("codeconcepto"));
		cdo.addColValue("tipo_emp",request.getParameter("tipoempleado"));
		cdo.addColValue("cod_reporte",request.getParameter("codeEstado"));
		cdo.addColValue("is_visible",request.getParameter("is_visible"));
		cdo.addColValue("genera_orden",request.getParameter("genera_orden"));
		cdo.addColValue("genera_asiento",request.getParameter("genera_asiento"));
		 
	  if (mode.equalsIgnoreCase("add"))
	  {
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.setAutoIncCol("cod_planilla");
		SQLMgr.insert(cdo);
	  }
	  else
	  {
		cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cod_planilla="+request.getParameter("id"));
		SQLMgr.update(cdo);
	  }
  }
  else if (tab.equals("1"))
  {
  		
	ArrayList list= new ArrayList();
	int keySize=Integer.parseInt(request.getParameter("eSize"));
	String itemRemoved="";
	iEstado.clear();
for(int a=0; a<keySize; a++)
{
  CommonDataObject cdox = new CommonDataObject();
  cdox.setTableName("tbl_pla_estado_emp_planilla");
  cdox.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cod_planilla="+id+" and cod_estado="+request.getParameter("cod_estado_old"+a));
  cdox.addColValue("cod_estado",request.getParameter("cod_estado"+a));
  cdox.addColValue("compania",""+(String) session.getAttribute("_companyId"));
  cdox.addColValue("cod_planilla",id);
  cdox.addColValue("fecha_modificacion",cDateTime);
  cdox.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdox.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+a));
  cdox.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+a));

  
  cdox.setKey(a);
  cdox.setAction(request.getParameter("action"+a));

    if (request.getParameter("remove"+a) != null && !request.getParameter("remove"+a).equals(""))
	{
		itemRemoved = cdox.getColValue("cod_estado");
		if (cdox.getAction().equalsIgnoreCase("I")) cdox.setAction("X");//if it is not in DB then remove it
		else cdox.setAction("D");
	}

	if (!cdox.getAction().equalsIgnoreCase("X"))
	{
		try
		{
			iEstado.put(cdox.getKey(),cdox);
			list.add(cdox);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}
 }//End For

if(!itemRemoved.equals(""))
{
//htdesc.remove(itemRemoved);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&id="+id+"&tab=1&mode="+mode);
return;
}
if (baction.equals("+"))
{
CommonDataObject cdo2 = new CommonDataObject();
cdo2.addColValue("cod_estado","");
cdo2.addColValue("fecha_creacion",cDateTime);
cdo2.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));

cdo2.setAction("I");
cdo2.setKey(iEstado.size() + 1);

iEstado.put(cdo2.getKey(),cdo2);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&id="+id+"&tab=1&mode="+mode);
 return;
}
if(list.size()==0){
CommonDataObject cdo3 = new CommonDataObject();
cdo3.setTableName("tbl_pla_estado_emp_planilla");
cdo3.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and id="+id);
cdo3.setKey(iEstado.size() + 1);
cdo3.setAction("I");
list.add(cdo3);
}
if (baction.equals("Guardar")){
ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 SQLMgr.saveList(list,true);
ConMgr.clearAppCtx(null);}
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/registro_planilla_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/registro_planilla_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/registro_planilla_list.jsp';
<%
	}
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>