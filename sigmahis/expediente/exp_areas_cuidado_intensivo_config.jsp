<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.AreaCuidadoIntensivo"%>
<%@ page import="issi.expediente.DetalleAreaCuidadoIntensivo"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ACIMgr" scope="page" class="issi.expediente.AreaCuidadoIntensivoMgr" />
<jsp:useBean id="iGrupo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iDet" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
ACIMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

AreaCuidadoIntensivo area = new AreaCuidadoIntensivo();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String tab = request.getParameter("tab");
String id = request.getParameter("id");
String change = request.getParameter("change");
int detLastLineNo = 0;
int grupoLastLineNo = 0;

if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (request.getParameter("detLastLineNo") != null) detLastLineNo = Integer.parseInt(request.getParameter("detLastLineNo"));
if (request.getParameter("grupoLastLineNo") != null) grupoLastLineNo = Integer.parseInt(request.getParameter("grupoLastLineNo"));

ArrayList alGrupo = new ArrayList();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	alGrupo = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_areas_cuid_inten_grupo where cod_area = "+id+" order by descripcion",CommonDataObject.class);
    
    if (mode.equalsIgnoreCase("add"))
	{
		iGrupo.clear();
		iDet.clear();
		id = "0";
		area.setCodigo(id);
	}
	else
	{
		if (id == null) throw new Exception("El Factor del Examen Físico no es válido. Por favor intente nuevamente!");

		sql = "select codigo, descripcion, estado usadoPor, presentar_check presentarCheck from tbl_sal_areas_cuid_intensivo where codigo = "+id+" order by 1";

		area = (AreaCuidadoIntensivo) sbb.getSingleRowBean(ConMgr.getConnection(),sql, AreaCuidadoIntensivo.class);

		if (change == null)
		{
			iDet.clear();
			iGrupo.clear();

			sql = "select codigo, cod_area codArea, cod_area_grupo codGrupo, descripcion, mostrar_observ mostrarObserv from tbl_sal_caract_areas_cuid_int where cod_area = "+id+" order by 1";

			al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleAreaCuidadoIntensivo.class);

			detLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++){
				DetalleAreaCuidadoIntensivo det = (DetalleAreaCuidadoIntensivo) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				det.setKey(key);

				iDet.put(key,det);
			}
            
            sql = "select codigo, codigo codGrupo, cod_area codAreaGrupo, descripcion from tbl_sal_areas_cuid_inten_grupo where cod_area = "+id+" order by 1";
            
            al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleAreaCuidadoIntensivo.class);
            
            grupoLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++){
				DetalleAreaCuidadoIntensivo det = (DetalleAreaCuidadoIntensivo) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				det.setKey(key);

				iGrupo.put(key,det);
			}

		}//change is null
	}//edit mode
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script>
document.title="AREAS CUIDADO INTENSIVO- "+document.title;

function doAction()
{
<%
if (request.getParameter("type") != null)
{
	if (tab.equals("1"))
	{
%>
<%
	}
}
%>
}

function removeDetail(k, noWarning){
    if (noWarning) {
      removeItem('form2',k);
	  form2BlockButtons(true);
	  document.form2.submit();
    } else {
      var grupo = eval('document.form1.codigo'+k).value;
      if(hasDBData('<%=request.getContextPath()%>','tbl_sal_caract_areas_cuid_int','cod_area_grupo = '+grupo+' and cod_area = <%=id%>','')){
		if(confirm('Las Características que están relacionadas a este grupo también se eliminarán. ¿Desea continuar?')){
			removeItem('form1',k);
			form1BlockButtons(true);
			document.form1.submit();
		}
	  }else {
            removeItem('form1',k);
			form1BlockButtons(true);
			document.form1.submit();
       }
    }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="1">
<tr>
	<td class="TableBorder">

<!-- MAIN DIV START HERE -->
<div id = "dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("detLastLineNo",""+detLastLineNo)%>
<%=fb.hidden("grupoLastLineNo",""+grupoLastLineNo)%>

		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="10%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="30%"><%=fb.intBox("codigo",area.getCodigo(),false,false,true,30,3)%></td>
			<td width="15%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td width="45%"><%=fb.textBox("descripcion",area.getDescripcion(),true,false,false,50,2000)%></td>
		</tr>
		<tr class="TextRow01">
			<td width="10%"><cellbytelabel id="3">Estado</cellbytelabel></td>
			<td colspan="3"><%=fb.select("estado","A=ACTIVO, I=INACTIVO",area.getEstado(),false,false,0,"Text10",null,null,"","")%>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer">Checkbox?&nbsp;
              <%=fb.checkbox("presentar_check","Y",area.getPresentarCheck()!=null&&area.getPresentarCheck().equalsIgnoreCase("Y"),false,null,null,"","")%></label>
            </td>
		</tr>

		<tr class="TextRow02">
			<td align="right" colspan="4">
				<cellbytelabel id="4">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N")%><cellbytelabel id="5">Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="6">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C")%><cellbytelabel id="7">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>

		</table>

<!-- TAB0 DIV END HERE-->
</div>

<!-- TAB1 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("detLastLineNo",""+detLastLineNo)%>
<%=fb.hidden("grupoLastLineNo",""+grupoLastLineNo)%>
<%=fb.hidden("size",""+iGrupo.size())%>

		<tr class="TextRow02">
			<td colspan="5">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="8">&Aacute;rea</cellbytelabel></td>
			<td colspan="4">[<%=area.getCodigo()%>] <%=area.getDescripcion()%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="90%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td width="3%">
                <%=fb.submit("addCol1","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
			</td>
		</tr>
<%
al = CmnMgr.reverseRecords(iGrupo);
for (int i = 1; i <= iGrupo.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleAreaCuidadoIntensivo det = (DetalleAreaCuidadoIntensivo) iGrupo.get(key);
	String displayDetalle = "";
	if (det.getStatus() != null && det.getStatus().equalsIgnoreCase("D")) displayDetalle = " style=\"display:none\"";
%>
		<%=fb.hidden("status"+i,det.getStatus())%>
		<%=fb.hidden("key"+i,det.getKey())%>
		<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01" align="center"<%=displayDetalle%>>
			<td><%=fb.intBox("codigo"+i,det.getCodigo(),false,false,true,5)%></td>
			<td><%=fb.textBox("descripcion"+i,det.getDescripcion(),true,false,false,85)%></td>
			<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeDetail("+i+")\"")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td align="right" colspan="5">
				<cellbytelabel id="4">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N")%>Crear Otro -->
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="6">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C")%><cellbytelabel id="7">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</table>

<!-- TAB1 DIV END HERE-->
</div>


<!-- TAB2 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("detLastLineNo",""+detLastLineNo)%>
<%=fb.hidden("grupoLastLineNo",""+grupoLastLineNo)%>
<%=fb.hidden("size",""+iDet.size())%>

		<tr class="TextRow02">
			<td colspan="5">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="8">&Aacute;rea</cellbytelabel></td>
			<td colspan="5">[<%=area.getCodigo()%>] <%=area.getDescripcion()%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="60%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="3">Grupo</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="3">Mostrar Observaci&oacute;n</cellbytelabel></td>
			<td width="3%">
                <%=fb.submit("addCol2","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
			</td>
		</tr>
<%
al = CmnMgr.reverseRecords(iDet);
for (int i = 1; i <= iDet.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleAreaCuidadoIntensivo det = (DetalleAreaCuidadoIntensivo) iDet.get(key);
	String displayDetalle = "";
	if (det.getStatus() != null && det.getStatus().equalsIgnoreCase("D")) displayDetalle = " style=\"display:none\"";
%>
		<%=fb.hidden("status"+i,det.getStatus())%>
		<%=fb.hidden("key"+i,det.getKey())%>
		<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01" align="center"<%=displayDetalle%>>
			<td><%=fb.intBox("codigo"+i,det.getCodigo(),false,false,true,5)%></td>
			<td><%=fb.textBox("descripcion"+i,det.getDescripcion(),true,false,false,85)%></td>
			<td>                
                <%=fb.select("cod_area_grupo"+i,alGrupo,det.getCodGrupo(),false,false,0,"","","","","S")%>
            </td>
            <td>
              <%=fb.checkbox("mostrar_observacion"+i,"S",det.getMostrarObserv()!=null&&det.getMostrarObserv().equalsIgnoreCase("S"),false,null,null,"","")%>
            </td>
			<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeDetail("+i+", 1)\"")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td align="right" colspan="6">
				<cellbytelabel id="4">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N")%>Crear Otro -->
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="6">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C")%><cellbytelabel id="7">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</table>

<!-- TAB2 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>

	</td>
</tr>
</table>
<script>
<%
String tabLabel = "'Area'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Grupos','Características'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
    
    System.out.println("----------------------------------------- tab = "+tab);
    System.out.println("----------------------------------------- baction = "+baction);

	if (tab.equals("0"))
	{
		area = new AreaCuidadoIntensivo();
		area.setCodigo(request.getParameter("id"));
		area.setDescripcion(request.getParameter("descripcion"));
		area.setEstado(request.getParameter("estado"));
        area.setPresentarCheck(request.getParameter("presentar_check")==null?"N":"Y");

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add"))
		{
			ACIMgr.add(area);
			id = ACIMgr.getPkColValue("codigo");
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
			ACIMgr.update(area);
		}
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("1"))
	{
        int size = Integer.parseInt(request.getParameter("size"));
		String itemRemoved = "";

		area = new AreaCuidadoIntensivo();
		area.setCodigo(request.getParameter("id"));
		area.getGrupo().clear();
		for (int i=1; i<=size; i++)
		{
			DetalleAreaCuidadoIntensivo det = new DetalleAreaCuidadoIntensivo();

			det.setCodigo(request.getParameter("codigo"+i));
			det.setDescripcion(request.getParameter("descripcion"+i));
			det.setStatus(request.getParameter("status"+i));

			det.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = det.getKey();
				det.setStatus("D");
			}
			try
			{
				iGrupo.put(det.getKey(),det);
				area.addGrupo(det);
                System.out.println("....................................................... 1 iGrupo.size() =  "+iGrupo.size());
                System.out.println("....................................................... 1 det.getCodigo =  "+det.getCodigo());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&detLastLineNo="+detLastLineNo+"&grupoLastLineNo="+grupoLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			DetalleAreaCuidadoIntensivo det = new DetalleAreaCuidadoIntensivo();

			grupoLastLineNo++;
			if (grupoLastLineNo < 10) key = "00" + grupoLastLineNo;
			else if (grupoLastLineNo < 100) key = "0" + grupoLastLineNo;
			else key = "" + grupoLastLineNo;
			det.setCodigo("0");
			det.setKey(key);

			try
			{
				iGrupo.put(det.getKey(),det);
                
                System.out.println("....................................................... 2 iGrupo.size() =  "+iGrupo.size());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&detLastLineNo="+detLastLineNo+"&grupoLastLineNo="+grupoLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ACIMgr.addGrupo(area);
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("2"))
	{
		int size = Integer.parseInt(request.getParameter("size"));
		String itemRemoved = "";

		area = new AreaCuidadoIntensivo();
		area.setCodigo(request.getParameter("id"));
		area.getDetalle().clear();
		for (int i=1; i<=size; i++)
		{
			DetalleAreaCuidadoIntensivo det = new DetalleAreaCuidadoIntensivo();

			det.setCodigo(request.getParameter("codigo"+i));
			det.setDescripcion(request.getParameter("descripcion"+i));
			det.setStatus(request.getParameter("status"+i));
			det.setCodGrupo(request.getParameter("cod_area_grupo"+i));
            
            if (request.getParameter("mostrar_observacion"+i)!=null) {
              det.setMostrarObserv("S");
            } else det.setMostrarObserv("N");

			det.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = det.getKey();
				det.setStatus("D");
			}

			try
			{
				iDet.put(det.getKey(),det);
				area.addDetalle(det);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&detLastLineNo="+detLastLineNo+"&grupoLastLineNo="+grupoLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			DetalleAreaCuidadoIntensivo det = new DetalleAreaCuidadoIntensivo();

			detLastLineNo++;
			if (detLastLineNo < 10) key = "00" + detLastLineNo;
			else if (detLastLineNo < 100) key = "0" + detLastLineNo;
			else key = "" + detLastLineNo;
			det.setCodigo("0");
			det.setKey(key);

			try
			{
				iDet.put(det.getKey(),det);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&detLastLineNo="+detLastLineNo+"&grupoLastLineNo="+grupoLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ACIMgr.addDetalle(area);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (ACIMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ACIMgr.getErrMsg()%>');
<%
	if (tab.equals("0"))
	{
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/exp_areas_cuidado_intensivo_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/exp_areas_cuidado_intensivo_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/exp_areas_cuidado_intensivo_list.jsp';
<%
	}
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
} else throw new Exception(ACIMgr.getErrMsg());
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