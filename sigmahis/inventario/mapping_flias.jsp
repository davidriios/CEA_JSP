<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iCtaFlia" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCtaFlia" scope="session" class="java.util.Vector"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
String key = "";
StringBuffer sbSql = new StringBuffer();
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String wh = request.getParameter("wh");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
boolean viewMode = false;
CommonDataObject cdoH = new CommonDataObject();
if (tab == null) tab = "0";
if (mode == null) mode = "edit";
if (fg == null) fg = "ctasFlias";
if (wh == null) wh = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
		
		sbSql.append("select a.codigo_almacen||' - '||a.descripcion as name,a.cg_cta1 cta1,a.cg_cta2 cta2, a.cg_cta3 cta3,a.cg_cta4 cta4,a.cg_cta5 cta5,a.cg_cta6 cta6,a.cg_cta1||' '||a.cg_cta2||' '||a.cg_cta3||' '||a.cg_cta4||' '||a.cg_cta5||' '||a.cg_cta6 cuenta  from tbl_inv_almacen a where a.codigo_almacen=");
		sbSql.append(wh);
		sbSql.append(" and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		cdoH = SQLMgr.getData(sbSql);

		if (change == null)
		{
			iCtaFlia.clear();
			vCtaFlia.clear();

			sbSql = new StringBuffer();
			sbSql.append("select a.wh,a.cod_flia as familia, a.cod_flia,a.compania,a.cta1,a.cta2,a.cta3,a.cta4,a.cta5,a.cta6,a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 cuenta,usuario_creacion,to_char(fecha_creacion,'dd/mm/yyy hh12:mi:ss am') as fecha_creacion,(select descripcion from tbl_inv_almacen where codigo_almacen=a.wh and compania=a.compania) descWh, a.cod_flia||' - '||(select nombre from tbl_inv_familia_articulo where cod_flia=a.cod_flia and compania=a.compania) descFlia,(select descripcion from tbl_con_catalogo_gral where cta1=a.cta1 and cta2=a.cta2 and cta3=a.cta3 and cta4=a.cta4 and cta5=a.cta5 and cta6=a.cta6 and compania=a.compania) descCuenta from tbl_con_ctas_x_flia a where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and a.wh =");
			sbSql.append(wh);
			sbSql.append(" order by 2");
			al  = SQLMgr.getDataList(sbSql);

			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try
				{
					iCtaFlia.put(cdo.getKey(), cdo);
					vCtaFlia.addElement(cdo.getColValue("cod_flia"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Inventario - Familias - '+document.title;
function doAction(){<%if (request.getParameter("type") != null && request.getParameter("type").equals("1")){%>abrir_ventana1('../common/check_familia.jsp?fp=ctasInv&id=<%=wh%>');<%}%>}
function clearRef(k)
{//eval('document.form0.id_ref'+k).value='';
//eval('document.form0.id_refDesc'+k).value='';
}
function showCtaList(k){var cta1=document.form0.ctawh1.value;var cta2=document.form0.ctawh2.value;var cta3=document.form0.ctawh3.value;var cta4=document.form0.ctawh4.value;var cta5=document.form0.ctawh5.value; 

var fgFilter ='';
if(cta1 !=''&&cta1 !='000')fgFilter+='&cta1='+cta1;
if(cta2 !=''&&cta2 !='00'&&cta2 !='000')fgFilter+='&cta2='+cta2;
if(cta3 !=''&&cta3 !='000')fgFilter+='&cta3='+cta3;
if(cta4 !=''&&cta4 !='000')fgFilter+='&cta4='+cta4;
if(cta5 !=''&&cta5 !='000')fgFilter+='&cta5='+cta5;
abrir_ventana1('../common/search_catalogo_gral.jsp?fp=<%=fg%>&mode=<%=mode%>&index='+k+fgFilter);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - CARGOS AUTOMATICOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("iSize",""+iCtaFlia.size())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("ctawh1",cdoH.getColValue("cta1"))%>
<%=fb.hidden("ctawh2",cdoH.getColValue("cta2"))%>
<%=fb.hidden("ctawh3",cdoH.getColValue("cta3"))%>
<%=fb.hidden("ctawh4",cdoH.getColValue("cta4"))%>
<%=fb.hidden("ctawh5",cdoH.getColValue("cta5"))%>
<%=fb.hidden("ctawh6",cdoH.getColValue("cta6"))%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr class="TextRow06">
					<td>ALMACEN:<%=cdoH.getColValue("name")%> &nbsp;&nbsp;&nbsp;&nbsp; CUENTA:<%=cdoH.getColValue("cuenta")%></td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(70)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="28">Familias por Almacen</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus70" style="display:none">+</label><label id="minus70">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel70">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="30%" align="left"><cellbytelabel>Familia</cellbytelabel></td>
							<td width="55%" align="left"><cellbytelabel>Cuenta</cellbytelabel></td>
							<td width="10%"><cellbytelabel>&nbsp;</cellbytelabel></td>
							<td width="5%"><%=fb.submit("btnaddCA","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
						</tr>

						<%
						al = CmnMgr.reverseRecords(iCtaFlia);
						for (int i=0; i<iCtaFlia.size(); i++)
						{
							key = al.get(i).toString();
							CommonDataObject cdo = (CommonDataObject) iCtaFlia.get(key);
						%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
						<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%=fb.hidden("cod_flia"+i,cdo.getColValue("cod_flia"))%>
						<%=fb.hidden("descFlia"+i,cdo.getColValue("descFlia"))%> 
						<%=fb.hidden("familia"+i,cdo.getColValue("familia"))%> 						
						<%=fb.hidden("cta1"+i,cdo.getColValue("cta1"))%>
						<%=fb.hidden("cta2"+i,cdo.getColValue("cta2"))%>
						<%=fb.hidden("cta3"+i,cdo.getColValue("cta3"))%>
						<%=fb.hidden("cta4"+i,cdo.getColValue("cta4"))%>
						<%=fb.hidden("cta5"+i,cdo.getColValue("cta5"))%>
						<%=fb.hidden("cta6"+i,cdo.getColValue("cta6"))%>				

						<%if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("descFlia")%></td>
							<td><%=fb.textBox("cuenta"+i,cdo.getColValue("cuenta"),true,false,true,20,null,null,null)%>
							<%=fb.textBox("descCuenta"+i,cdo.getColValue("descCuenta"),true,false,true,60,null,null,null)%>
							<%=fb.button("btnRefOrg"+i,"...",true,viewMode,"Text10",null,"onClick=\"javascript:showCtaList("+i+")\"")%></td>
							<td  align="center"><%//=fb.select("estado"+i,"A=Activo,I=Inactivo",cdo.getColValue("estado"),false,false,0,"Text10","","")%></td>
							<td align="center">&nbsp;<%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
						</tr>
						<%}
						}
						fb.appendJsValidation("if(error>0)doAction();");
						%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N")%><cellbytelabel id="16">Crear Otro </cellbytelabel>-->
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="18">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB5 DIV END HERE-->
</div>
<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
//if (mode.equalsIgnoreCase("add"))
//{
%>
initTabs('dhtmlgoodies_tabView1',['Cuentas x Familias'],0,'100%','');
<%
/*}
else
{]*/
%>
//initTabs('dhtmlgoodies_tabView1',Array('Procedimientos','Insumos','Usos','Personal','Honorarios','Maletin Anestesia','Niveles de Precio'),<%=tab%>,'100%','');
<%
//}
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
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	if (tab.equals("0")) //NIVEL DE PRECIO
	{
		int size = 0;
		if (request.getParameter("iSize") != null) size = Integer.parseInt(request.getParameter("iSize"));
		String itemRemoved = "";

		al.clear();
		iCtaFlia.clear();
		vCtaFlia.clear();
		int lineNo = 0;
		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_con_ctas_x_flia");
			cdo.setWhereClause("wh = "+request.getParameter("wh")+" and cod_flia="+request.getParameter("familia"+i)+" and compania="+(String) session.getAttribute("_companyId"));
			
			cdo.addColValue("cta1",request.getParameter("cta1"+i));
			cdo.addColValue("cta2",request.getParameter("cta2"+i));
			cdo.addColValue("cta3",request.getParameter("cta3"+i));
			cdo.addColValue("cta4",request.getParameter("cta4"+i));
			cdo.addColValue("cta5",request.getParameter("cta5"+i));
			cdo.addColValue("cta6",request.getParameter("cta6"+i));
			cdo.addColValue("familia",request.getParameter("familia"+i));
			cdo.addColValue("cuenta",request.getParameter("cuenta"+i));
			cdo.addColValue("descFlia",request.getParameter("descFlia"+i));
			cdo.addColValue("descCuenta",request.getParameter("descCuenta"+i));
			//cdo.addColValue("estado",request.getParameter("estado"+i));

			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			if (cdo.getAction().equalsIgnoreCase("I")){cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
			cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));}
			cdo.addColValue("fecha_modificacion","sysdate");
			cdo.setKey(i);
			
			
			cdo.setAction(request.getParameter("action"+i));
			if (cdo.getAction().equalsIgnoreCase("I")){
			cdo.addColValue("wh",request.getParameter("wh"));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));

			cdo.addColValue("cod_flia",request.getParameter("cod_flia"+i));}
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{   iCtaFlia.put(cdo.getKey(),cdo);
					vCtaFlia.add(cdo.getColValue("familia"));
					
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=0&mode=edit&wh="+wh+"&fg="+fg);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=0&type=1&mode=edit&wh="+wh+"&fg="+fg);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_con_ctas_x_flia");
			cdo.setWhereClause("compania = "+session.getAttribute("_companyId")+" and wh="+wh);
			cdo.setAction("I");
			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&wh="+wh+"&fg="+fg);
		SQLMgr.saveList(al, true, true);
		ConMgr.clearAppCtx(null);
	} //END TAB 0
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&wh=<%=wh%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
