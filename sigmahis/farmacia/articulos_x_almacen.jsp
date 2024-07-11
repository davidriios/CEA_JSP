<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iArticulosBmWh" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vArticulosBmWh" scope="session" class="java.util.Vector"/> 
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
ArrayList alanaque= new ArrayList();
StringBuffer sbSql = new StringBuffer();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String mode = request.getParameter("mode");
String type = request.getParameter("type");
String key = "";
String change = request.getParameter("change");
String compania = (String) session.getAttribute("_companyId");
if (mode == null) mode = "add";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String wh=request.getParameter("wh");
if (wh == null) wh = "";
String sql="";
if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (!wh.trim().equals(""))
		{
			sql="select codigo as optValueColumn, descripcion as optLabelColumn from tbl_inv_anaqueles_x_almacen where compania="+(String) session.getAttribute("_companyId")+"  and codigo_almacen="+wh+" order by 2";
			alanaque = sbb.getBeanList(ConMgr.getConnection(), sql, CommonDataObject.class);                   
		}
		if (change == null)
		{
			iArticulosBmWh.clear();
			vArticulosBmWh.clear(); 
		if (!wh.trim().equals(""))
		{ 
			
			sbSql.append("select bm.product_id,bm.compania, bm.cod_flia, bm.cod_clase, bm.cod_articulo, a.descripcion,bm.estado,bm.cod_subclase,bm.cod_flia||'-'||bm.cod_clase||'-'||bm.cod_subclase||'-'||bm.cod_articulo artKey, i.precio,i.disponible,i.usuario_creacion, to_char(i.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion,i.codigo_anaquel,i.estado from tbl_inv_articulo a, tbl_inv_articulo_bm bm , tbl_inv_inventario i where  bm.compania =a.compania  and bm.cod_articulo =a.cod_articulo and a.compania=");  
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and  i.cod_articulo = bm.cod_articulo and i.compania=bm.compania and i.codigo_almacen=");
			sbSql.append(wh);
			sbSql.append(" order by bm.cod_flia, bm.cod_clase,a.descripcion");
			al = SQLMgr.getDataList(sbSql.toString());
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);
				cdo.setKey(i);
				cdo.setAction("U");
				try
				{
					iArticulosBmWh.put(cdo.getKey(), cdo);
					vArticulosBmWh.addElement(cdo.getColValue("artKey"));
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="Artículo - Agregar - "+document.title;
</script>
<script type="text/javascript">
function doAction()
{
	<%
	if(type!=null && type.equals("1")){
	%>
	 var wh = document.form1.wh.value;
	if(wh!='')abrir_ventana1('../inventario/sel_articles_kb.jsp?mode=<%=mode%>&fp=articlesBmWh&codAlmacen='+wh);
	else CBMSG.alert('SELECCIONE ALMACEN');
	<%
	}
	%>
}
function doSearch()
{
var wh =  document.form1.wh.value;
window.location = '../farmacia/articulos_x_almacen.jsp?wh='+wh;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
					<table align="center" width="99%" cellpadding="0" cellspacing="0">

						<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("clearHT","")%>
	<%=fb.hidden("baction","")%>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<tr class="TextRow02">
		<td colspan="4">Almacen:</cellbytelabel>:<%=fb.select(ConMgr.getConnection(),"SELECT distinct a.almacen, b.descripcion||' - '||a.almacen, a.almacen FROM tbl_sec_cds_almacen a,tbl_inv_almacen b where a.almacen=b.codigo_almacen and b.compania="+(String) session.getAttribute("_companyId") +" and is_bm = 'Y' ORDER  BY 1","wh",wh,false,(!wh.trim().equals("")),0,"Text10",null,"onChange=\"javascript:doSearch()\"",null,"S")%></td>
	</tr>
		<tr id="panel0">
			<td colspan="4">
				<table width="100%" align="center">
					<tr class="TextHeader" align="center">
						<td colspan="7" align="right">
						<%=fb.submit("addArticles","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Articulos de Banco de Medicamentos")%>
					</tr>
					<tr class="TextHeader" align="center">
						<td colspan="3">C&oacute;digo</td>
						<td rowspan="2" width="36%">Descripci&oacute;n</td>
						<td rowspan="2" width="5%">&nbsp;</td>
						<td rowspan="2" width="2%">&nbsp;</td>
						<td rowspan="2" width="2%">&nbsp;</td>
					</tr>
					<tr class="TextHeader" align="center">
						<td width="5%">Familia</td>
						<td width="5%">Clase</td>
						<td width="10%">Art&iacute;culo</td>
					</tr>
					<%
					if (iArticulosBmWh.size() > 0) al = CmnMgr.reverseRecords(iArticulosBmWh);

					for (int i=0; i<iArticulosBmWh.size(); i++)
					{
						key = al.get(i).toString();
						CommonDataObject cdo = (CommonDataObject) iArticulosBmWh.get(key);
						String color = "";
						if (i%2 == 0) color = "TextRow02";
						else color = "TextRow01";
					%>
					<%=fb.hidden("cod_flia"+i,cdo.getColValue("cod_flia"))%>
					<%=fb.hidden("cod_clase"+i,cdo.getColValue("cod_clase"))%>
					<%=fb.hidden("cod_articulo"+i,cdo.getColValue("cod_articulo"))%>
					<%=fb.hidden("cod_subclase"+i,cdo.getColValue("cod_subclase"))%>
					<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
					<%=fb.hidden("artKey"+i,cdo.getColValue("artKey"))%>
					<%=fb.hidden("remove"+i,"")%>
					<%=fb.hidden("key"+i,cdo.getKey())%>
					<%=fb.hidden("action"+i,cdo.getAction())%>
					<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
					<%=fb.hidden("usuario_modif"+i,cdo.getColValue("usuario_modif"))%>
					<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
					<%=fb.hidden("fecha_modif"+i,cdo.getColValue("fecha_modif"))%>
					<%=fb.hidden("product_id"+i,cdo.getColValue("product_id"))%>
					<%=fb.hidden("cod_ref"+i,cdo.getColValue("cod_ref"))%>
					<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
					<%=fb.hidden("disponible"+i,cdo.getColValue("disponible"))%>
					
					<%if(!cdo.getAction().equalsIgnoreCase("D")){%>
					<tr class="<%=color%>" align="center">
						<td><%=cdo.getColValue("cod_flia")%></td>
						<td><%=cdo.getColValue("cod_clase")%></td>
						<td><%=cdo.getColValue("cod_articulo")%></td>
						<td align="left"><%=cdo.getColValue("descripcion")%></td>
						<td align="center"><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"),false,false,0,"Text10",null,null,null,"S")%></td>
						<td align="center"><%=fb.select("codigo_anaquel"+i,alanaque,cdo.getColValue("codigo_anaquel"),false,false,0,"Text10",null,null,null,"S")%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,(!cdo.getAction().equalsIgnoreCase("I")),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
					</tr>
				<%}}%>
				<%=fb.hidden("keySize",""+iArticulosBmWh.size())%>
				</table>
		</tr>
		<tr class="TextRow02">
										<td colspan="4" align="right">
										Opciones de Guardar:
										<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro
										<%//=fb.radio("saveOption","O",true,false,false)%>
					<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
										<%=fb.radio("saveOption","C",false,false,false)%>Cerrar
					<%//=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmitArt()\"")%>
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
										</td>
									</tr>
									<tr>
										<td colspan="4">&nbsp;</td>
									</tr>
									<%=fb.formEnd(true)%>
									<!-- ================================   F O R M   E N D   H E R E   ================================ -->
								</table>
				</td>
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
String clearHT = request.getParameter("clearHT");
String baction = request.getParameter("baction");
String itemRemoved = "";
int size = 0;
	if (request.getParameter("keySize") != null)
	size = Integer.parseInt(request.getParameter("keySize"));
	iArticulosBmWh.clear();
	vArticulosBmWh.clear();
	al.clear();	
	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_inv_inventario");
		cdo.setWhereClause("compania="+compania+" and codigo_almacen="+request.getParameter("wh")+" and cod_articulo="+request.getParameter("cod_articulo"+i));
		cdo.addColValue("compania",compania);
		cdo.addColValue("cod_flia",request.getParameter("cod_flia"+i));
		cdo.addColValue("art_familia",request.getParameter("cod_flia"+i));
		cdo.addColValue("cod_clase",request.getParameter("cod_clase"+i));
		cdo.addColValue("art_clase",request.getParameter("cod_clase"+i));
		cdo.addColValue("cod_articulo",request.getParameter("cod_articulo"+i));
		cdo.addColValue("codigo_almacen",request.getParameter("wh"));
		
		cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));
		cdo.addColValue("fecha_modificacion",cDateTime);
		cdo.addColValue("product_id",request.getParameter("product_id"+i));
		cdo.addColValue("cod_subclase",request.getParameter("cod_subclase"+i));
		  
		cdo.addColValue("artKey",request.getParameter("artKey"+i));
		cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
		cdo.addColValue("codigo_anaquel",request.getParameter("codigo_anaquel"+i));
		cdo.addColValue("estado",request.getParameter("estado"+i));
		
		cdo.setKey(i);
		cdo.setAction(request.getParameter("action"+i));
		
		if (cdo.getAction().equalsIgnoreCase("I"))cdo.addColValue("precio",request.getParameter("precio"+i));
		if (cdo.getAction().equalsIgnoreCase("I"))cdo.addColValue("disponible","0");
		
		
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
					iArticulosBmWh.put(cdo.getKey(),cdo);
					vArticulosBmWh.add(cdo.getColValue("artKey"));
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
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1mode="+mode+"&wh="+wh);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&wh="+wh);
		return;
	}

	if (al.size() == 0)
	{
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_inv_inventario");
		cdo.setWhereClause("compania="+compania+" and cod_articulo=0 and estado ='X' ");
		cdo.setAction("I");
		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.saveList(al,true);
	ConMgr.clearAppCtx(null);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/farmacia/list_medicamentos_banco.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/farmacia/list_medicamentos_banco.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/farmacia/list_medicamentos_banco.jsp';
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
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&wh=<%=wh%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
