<%@ page errorPage="../error.jsp"%>
<%@ page import="java.io.File"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iClases" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vClases" scope="session" class="java.util.Vector"/>
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
ArrayList alWh = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String key = "";
StringBuffer sbSql = new StringBuffer();
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String familia = request.getParameter("familia");
String change = request.getParameter("change");
String clase = request.getParameter("clase");
String fg = request.getParameter("fg");
boolean viewMode = false;

if (tab == null) tab = "0";
if (mode == null) mode = "edit";
if (fg == null) fg = "CL";
if (clase == null) clase = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;


if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql = new StringBuffer(); 
	sbSql.append("select codigo_almacen as optValueColumn, descripcion||' - '||codigo_almacen as optLabelColumn, codigo_almacen as optTitleColumn from tbl_inv_almacen where compania =");
	sbSql.append(session.getAttribute("_companyId"));
	alWh = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
	 
		if (change == null)
		{
			iClases.clear();
			vClases.clear();

			sbSql = new StringBuffer();
			sbSql.append("select id, familia, clase, compania, comentario, estado, usuario_creacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, (select nombre from tbl_inv_familia_articulo where cod_flia = a.familia and compania = a.compania) as familia_desc,(select descripcion from tbl_inv_clase_articulo where cod_clase = a.clase and cod_flia = a.familia and compania = a.compania) as clase_desc,almacen from tbl_inv_wh_familia_clases_sop a where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" order by 1");
			al  = SQLMgr.getDataList(sbSql);

			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try
				{
					iClases.put(cdo.getKey(), cdo);
					if(cdo.getColValue("estado").trim().equals("A"))vClases.addElement(cdo.getColValue("familia")+"-"+cdo.getColValue("clase"));
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
document.title = 'Inventario -  Edición - '+document.title;
function doAction(){}
function clearRef(k)
{//eval('document.form0.id_ref'+k).value='';
//eval('document.form0.id_refDesc'+k).value='';
}
function showRefList(fg,k){var flia ='<%=familia%>';
abrir_ventana1('../inventario/list_subclase.jsp?fg='+fg+'&mode=<%=mode%>&familia='+flia+'&index='+k);}
function showFamilia(fg,k){var flia ='<%=familia%>';
abrir_ventana1('../inventario/list_familia.jsp?fg='+fg+'&mode=<%=mode%>&familia='+flia+'&index='+k);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - CONFIGURACION DE ALMACEN SOP "></jsp:param>
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
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("iSize",""+iClases.size())%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("fg",fg)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(70)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="28">Almacen de Sop por familia y clase</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus70" style="display:none">+</label><label id="minus70">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel70">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="8%"><cellbytelabel>Familia</cellbytelabel></td>
							<td width="8%" align="left"><cellbytelabel>Clase</cellbytelabel></td>
							<td width="8%" align="left"><cellbytelabel>Almacen</cellbytelabel></td> 
							<td width="8%"><cellbytelabel>Comentario</cellbytelabel></td>
							<td width="8%"><cellbytelabel>Estado</cellbytelabel></td>
							<td width="2%"><%=fb.submit("btnaddCA","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
						</tr>

						<%
						al = CmnMgr.reverseRecords(iClases);
						for (int i=0; i<iClases.size(); i++)
						{
							key = al.get(i).toString();
							CommonDataObject cdo = (CommonDataObject) iClases.get(key);
							String nF = "familia"+i;
							String nClase = "clase"+i;
						%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
						<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%=fb.hidden("id"+i,cdo.getColValue("id"))%>

						<%//=fb.hidden("familia"+i,cdo.getColValue("familia"))%>
						<%//=fb.hidden("clase"+i,cdo.getColValue("clase"))%> 
						<%if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01">
							<td><%=fb.select("familia"+i,"","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','"+nClase+"','"+cdo.getColValue("clase")+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','<%=nF%>','<%=cdo.getColValue("familia")%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
		</script>		</td>
							<td><%=fb.select("clase"+i,"","")%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','<%=nClase%>','<%=cdo.getColValue("clase")%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(cdo.getColValue("familia") != null && !cdo.getColValue("familia").equals(""))?cdo.getColValue("familia"):"document.form0.familia"+i+".value"%>,'KEY_COL','T');
		</script>	</td>
						
							<td  align="center"><%=fb.select("almacen"+i,alWh,cdo.getColValue("almacen"),false,false,0,"Text10",null,null,"","","")%></td> 
							<td><%=fb.textarea("comentario"+i,cdo.getColValue("comentario"),false,false,false,25,1,null,null,null)%></td>
							<td  align="center"><%=fb.select("estado"+i,"A=Activo,I=Inactivo",cdo.getColValue("estado"),false,false,0,"Text10","","")%></td>
							<td>&nbsp;<%=(cdo.getAction().equalsIgnoreCase("I"))?fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar"):""%></td>
						</tr>
						<%}
						}
						fb.appendJsValidation("if(error>0)doAction();");
							//fb.appendJsValidation("\n\tif (!CheckRef())\n\t{\n\t\t\n\t\terror++;\n\t}\n");

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
initTabs('dhtmlgoodies_tabView1',['Almacen sop'],0,'100%','');
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
		iClases.clear();
		vClases.clear();
		int lineNo = 0;
		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_inv_wh_familia_clases_sop");
			cdo.setWhereClause("id = "+request.getParameter("id"+i));
			if(request.getParameter("id"+i).trim().equals("0"))
			{
				cdo.setAutoIncCol("id");
				cdo.addPkColValue("id","");
			}
			cdo.addColValue("id",request.getParameter("id"+i));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));

			cdo.addColValue("familia",request.getParameter("familia"+i));
			cdo.addColValue("clase",request.getParameter("clase"+i));
			//cdo.addColValue("sub_clase",request.getParameter("sub_clase"+i)); 

			cdo.addColValue("familia_desc",request.getParameter("familia_desc"+i));
			cdo.addColValue("clase_desc",request.getParameter("clase_desc"+i));
			cdo.addColValue("sub_clase_desc",request.getParameter("sub_clase_desc"+i)); 
			cdo.addColValue("almacen",request.getParameter("almacen"+i)); 

			cdo.addColValue("estado",request.getParameter("estado"+i));

			cdo.addColValue("comentario",request.getParameter("comentario"+i));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
			cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));
			cdo.addColValue("fecha_modificacion","sysdate");
			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					iClases.put(cdo.getKey(),cdo);
					if(cdo.getColValue("estado").trim().equals("A"))vClases.add(cdo.getColValue("familia")+"-"+cdo.getColValue("clase"));
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
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=0&mode=edit&familia="+familia+"&clase="+clase+"&fg="+fg);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("id","0");
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("estado","");
			cdo.addColValue("comentario","");
			cdo.addColValue("fecha_creacion","sysdate");
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion","");
			cdo.addColValue("fecha_modificacion","");
			cdo.addColValue("other1","");
			cdo.addColValue("other2","");
			cdo.addColValue("other3","");
			cdo.setAction("I");
			cdo.setKey(iClases.size()+1);
			iClases.put(cdo.getKey(),cdo);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=0&type=1&mode=edit&familia="+familia+"&clase="+clase+"&fg="+fg);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_inv_wh_familia_clases_sop");
			cdo.setWhereClause("compania = "+session.getAttribute("_companyId"));
			cdo.setAction("I");
			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&familia="+familia+"&clase="+clase+"&fg="+fg);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&familia=<%=familia%>&clase=<%=clase%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
