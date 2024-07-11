<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDet" scope="session" class="java.util.Vector"/>

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

int iconHeight = 24;
int iconWidth = 24;
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String key = "";
StringBuffer sbSql;
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String id = request.getParameter("id");
String fecha="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String fp = request.getParameter("fp");
if (fg == null) fg = "";
if (tab == null) tab = "0";
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) { viewMode = true;}
if (fp == null) fp = "adm";
String loadInfo = request.getParameter("loadInfo");
if (loadInfo == null) loadInfo = "N";
String apl_desc_global = SQLMgr.getData("select nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'APL_DESC_GLOBAL_POS'), 'N') as apl_desc_global from dual").getColValue("apl_desc_global");


if (request.getMethod().equalsIgnoreCase("GET") && loadInfo.equals("S"))
{
	if (change == null){
	
		iDet.clear();
		vDet.clear();
		if (id == null) throw new Exception("El Id de descuento no es válido. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("select compania, id_descuento, secuencia, tipo_desc, codigo, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_creacion, observacion, estado, decode(tipo_desc, 'F', (select nombre from tbl_inv_familia_articulo f where f.cod_flia = d.codigo and f.compania = d.compania), 'A', (select descripcion from tbl_inv_articulo a where a.cod_articulo = d.codigo and a.compania = d.compania), 'C', (select descripcion from tbl_caf_menu m where m.id = d.codigo and m.compania = d.compania)) descripcion, nvl((select es_desc_global from tbl_par_descuento pd where pd.compania = d.compania and pd.id = d.id_descuento), 'N') es_desc_global from tbl_par_descuento_det d where compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and id_descuento = ");
		sbSql.append(id);
		al  = SQLMgr.getDataList(sbSql.toString());
		System.out.println("detalle descuento query...\n"+sbSql.toString());

		
		for (int i=1; i<=al.size(); i++)
		{
			CommonDataObject obj = (CommonDataObject) al.get(i-1);
			obj.setKey(i);

			try
			{
				iDet.put(obj.getKey(), obj);
				vDet.addElement(obj.getColValue("tipo_desc")+"_"+obj.getColValue("codigo"));
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
document.title = 'Admisión - '+document.title;
function showDetalle(tipo_desc){
	if(tipo_desc=='F') abrir_ventana1('../common/check_familia.jsp?fp=descuento_pos&tipo_desc='+tipo_desc);
	else if(tipo_desc=='A') abrir_ventana1('../common/check_articulo.jsp?fp=descuento_pos&tipo_desc='+tipo_desc);
}


function doAction(){
newHeight();
<%
	if (request.getParameter("type") != null && request.getParameter("type").equals("1")){
%>
	abrir_ventana1('../common/check_familia.jsp?fp=descuento');
<%
	} else if (request.getParameter("type") != null && request.getParameter("type").equals("2")){
%>
	abrir_ventana1('../common/check_articulo.jsp?fp=descuento');
<%
	}
%>
}


function doSubmit(valor){
	document.form1.baction.value=valor;
	document.form1.id_descuento.value=parent.document.form1.id.value;
	document.form1.submit();
}
//window.notAValidDate;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
	<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("tab","1")%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("id_descuento",id)%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("detSize",""+iDet.size())%>
		<table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextHeader" align="center">
				<td width="10%"><cellbytelabel id="16">Tipo</cellbytelabel></td>
				<td width="15%" align="center"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
				<td width="60%"><cellbytelabel id="2">Descripcion</cellbytelabel></td>
				<td width="15%"><%=fb.button("addFlia","Familias",false,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value);\"","Agregar Familias")%><%=fb.button("addProduct","Articulos",false,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value);\"","Agregar Articulos")%></td>
			</tr>
		<%
		al = CmnMgr.reverseRecords(iDet);
		for (int i=1; i<=iDet.size(); i++)
		{
		key = al.get(i - 1).toString();
		CommonDataObject obj = (CommonDataObject) iDet.get(key);
		%>
			<%=fb.hidden("tipo_desc"+i,obj.getColValue("tipo_desc"))%>
			<%=fb.hidden("codigo"+i,obj.getColValue("codigo"))%>
			<%=fb.hidden("descripcion"+i,obj.getColValue("descripcion"))%>
			<%=fb.hidden("secuencia"+i,obj.getColValue("secuencia"))%>
			<%=fb.hidden("es_desc_global"+i,obj.getColValue("es_desc_global"))%>
			<tr class="TextRow01">
				<td align="center"><%=(obj.getColValue("tipo_desc").equals("F")?"Familia":"Articulo")%></td>
				<td align="center"><%=obj.getColValue("codigo")%></td>
				<td><%=obj.getColValue("descripcion")%></td>
				<td align="center">
				<%if(obj.getColValue("secuencia").equals("0")){%>
				<%=fb.submit("del"+i,"X",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%//=fb.button("rem"+i,"X",true, viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+"); doSubmit(this.value);\"","Eliminar Detalle")%>
				<%} else {
					
					%>
				<%=fb.select("estado"+i,"A=Activo,I=Inactivo"+(apl_desc_global.equals("S") && obj.getColValue("es_desc_global").equals("S")?",E=Excepcion":""),obj.getColValue("estado"),false,false,0,null,null,null)%>
				<%}%>
				</td>
			</tr>
		<%
		}
		%>
			<tr class="TextRow02">
				<td align="right" colspan="4">
					Opciones de Guardar:
					<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
					<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
					<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
				</td>
			</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else if(request.getMethod().equalsIgnoreCase("POST"))
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
		
		int size = 0;
		if (request.getParameter("detSize") != null) size = Integer.parseInt(request.getParameter("detSize"));
		String itemRemoved = "";
		iDet.clear();
		vDet.clear();
		al = new ArrayList();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject obj = new CommonDataObject();
			obj.setTableName("tbl_par_descuento_det");
			obj.addColValue("compania", (String) session.getAttribute("_companyId"));
			obj.addColValue("id_descuento", request.getParameter("id_descuento"));
			obj.addColValue("tipo_desc", request.getParameter("tipo_desc"+i));
			obj.addColValue("codigo", request.getParameter("codigo"+i));
			obj.addColValue("descripcion", request.getParameter("descripcion"+i));
			obj.addColValue("secuencia", request.getParameter("secuencia"+i));
			obj.addColValue("es_desc_global", request.getParameter("es_desc_global"+i));
			
			if(request.getParameter("secuencia"+i)!=null && request.getParameter("secuencia"+i).equals("0")){
				obj.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
				obj.setAutoIncCol("secuencia");
				obj.setAutoIncWhereClause("compania = "+(String) session.getAttribute("_companyId")+" and id_descuento = "+request.getParameter("id_descuento"));
				obj.setAction("I");
			} else if(request.getParameter("secuencia"+i)!=null && !request.getParameter("secuencia"+i).equals("0")){
				obj.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
				obj.setWhereClause("compania = "+(String) session.getAttribute("_companyId")+" and id_descuento = "+request.getParameter("id_descuento") + " and secuencia = "+request.getParameter("secuencia"+i));
				obj.setAction("U");
			}
			if(request.getParameter("estado"+i)!=null) obj.addColValue("estado", request.getParameter("estado"+i));

			if (request.getParameter("del"+i) != null && !request.getParameter("del"+i).equals(""))
				itemRemoved = "1";
			else
			{
				try
				{
					obj.setKey(i);
					iDet.put(obj.getKey(),obj);
					vDet.add(obj.getColValue("tipo_desc")+"_"+obj.getColValue("codigo"));
					System.out.println("key..."+obj.getKey());
					al.add(obj);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&id="+id+"&loadInfo=S");
			return;
		}
		
		System.out.println("baction="+request.getParameter("baction"));

		if (baction != null && (baction.equals("Familias") || baction.equals("Articulos")))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&type="+(baction.equals("Familias")?1:2)+"&mode="+mode+"&id="+id+"&loadInfo=S");
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al, true, false);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&mode=edit&tab=<%=tab%>&id=<%=request.getParameter("id_descuento")%>&loadInfo=S';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&mode=edit&tab=<%=tab%>&id=<%=request.getParameter("id_descuento")%>&loadInfo=S';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>