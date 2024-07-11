<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.AreaCorporal"%>
<%@ page import="issi.expediente.DetalleCara"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ACMgr" scope="page" class="issi.expediente.AreaCorporalMgr" />
<jsp:useBean id="iDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iCds" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCds" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
ACMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

AreaCorporal area = new AreaCorporal();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String tab = request.getParameter("tab");
String id = request.getParameter("id");
String change = request.getParameter("change");
int detLastLineNo = 0;
int cdsLastLineNo = 0;

if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (request.getParameter("detLastLineNo") != null) detLastLineNo = Integer.parseInt(request.getParameter("detLastLineNo"));
if (request.getParameter("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt(request.getParameter("cdsLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		iDet.clear();
		iCds.clear();
		vCds.clear();
		id = "0";
		area.setCodigo(id);
	}
	else
	{
		if (id == null) throw new Exception("El Factor del Examen Físico no es válido. Por favor intente nuevamente!");

		sql = "select codigo, descripcion,usado_por usadoPor, orden from tbl_sal_examen_areas_corp where codigo="+id+" order by 1";
		//System.out.println("SQL="+sql);
		area = (AreaCorporal) sbb.getSingleRowBean(ConMgr.getConnection(),sql, AreaCorporal.class);

		if (change == null)
		{
			iDet.clear();
			iCds.clear();
			vCds.clear();

			sql = "select codigo, cod_area_corp, descripcion,usado_por usadoPor, orden from tbl_sal_caract_areas_corp where cod_area_corp="+id+" order by 1";
			//System.out.println("SQL="+sql);
			al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleCara.class);

			detLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				DetalleCara det = (DetalleCara) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				det.setKey(key);

				iDet.put(key,det);
			}

			sql = "select a.centro_servicio as codigo, a.observacion, a.sec_orden as secOrden, b.descripcion from tbl_sal_examen_area_corp_x_cds a, tbl_cds_centro_servicio b where a.cod_area="+id+" and a.centro_servicio=b.codigo order by 1";
			//System.out.println("SQL="+sql);
			al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleCara.class);

			cdsLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				DetalleCara det = (DetalleCara) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				det.setKey(key);

				iCds.put(key,det);
				vCds.addElement(det.getCodigo());
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
<script language="javascript">
document.title="Factores a Evaluar en el Examen Físico - "+document.title;

function doAction()
{
<%
if (request.getParameter("type") != null)
{
	if (tab.equals("1"))
	{
%>
	 showCdsList();
<%
	}
}
%>
}

function showCdsList()
{
  abrir_ventana1('../common/check_cds.jsp?fp=areaCorporal&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&detLastLineNo=<%=detLastLineNo%>');
}

function removeDetail(k)
{
	var caract = eval('document.form2.codigo'+k).value;

	if(hasDBData('<%=request.getContextPath()%>','tbl_sal_caract_area_corp_x_cds','cod_caract='+caract+' and cod_area=<%=id%>',''))
	{
		if(confirm('Los Centros de Servicios que están relacionado a esta característica también se eliminarán. ¿Desea continuar?'))
		{
			removeItem('form2',k);
			form2BlockButtons(true);
			document.form2.submit();
		}
	}
	else
	{
		removeItem('form2',k);
		form2BlockButtons(true);
		document.form2.submit();
	}
}

function setCds(caract){
	if(caract=='0')alert('Por favor guarde antes de continuar!');
	else showPopWin('../expediente/area_caract_cds.jsp?id=<%=id%>&caract='+caract,winWidth*.95,winHeight*.85,null,null,'');
}

function setSubCaract(codCaract, caractDesc) {
  if (!codCaract) alert('Por favor guarde antes de continuar!');
  else showPopWin('../expediente/sub_area_caract.jsp?caract='+codCaract+'&area=<%=id%>&area_desc=<%=area.getDescripcion()%>&caract_desc='+caractDesc,winWidth*.95,winHeight*.85,null,null,'');
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
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>

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
			<td width="10%"><cellbytelabel id="3">Usado Por</cellbytelabel></td>
			<td colspan="3"><%=fb.select("usado_por","M=MEDICO, E=ENFERMERA,T=TODOS",area.getUsadoPor(),false,false,0,"Text10",null,null,"","")%>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            Orden:
            <%=fb.intBox("orden",area.getOrden(),false,false,false,6,2)%>
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
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("size",""+iCds.size())%>

		<tr class="TextRow02">
			<td colspan="5">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="8">&Aacute;rea</cellbytelabel></td>
			<td colspan="4">[<%=area.getCodigo()%>] <%=area.getDescripcion()%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="40%"><cellbytelabel id="2">Descripci&oacute;n<</cellbytelabel>/td>
			<td width="40%"><cellbytelabel id="9">Observaci&oacute;n</cellbytelabel></td>
			<td width="7%"><cellbytelabel id="10">Orden</cellbytelabel></td>
			<td width="3%"><%=fb.submit("addCds","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Centro de Servicios")%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iCds);
for (int i=1; i<=iCds.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleCara det = (DetalleCara) iCds.get(key);
%>
<%=fb.hidden("key"+i,det.getKey())%>
<%=fb.hidden("codigo"+i,det.getCodigo())%>
<%=fb.hidden("descripcion"+i,det.getDescripcion())%>
<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01">
			<td align="center"><%=det.getCodigo()%></td>
			<td><%=det.getDescripcion()%></td>
			<td align="center"><%=fb.textBox("observacion"+i,det.getObservacion(),false,false,false,50)%></td>
			<td align="center"><%=fb.intBox("secOrden"+i,det.getSecOrden(),false,false,false,5,5)%></td>
			<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
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
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("size",""+iDet.size())%>

		<tr class="TextRow02">
			<td colspan="6">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="8">&Aacute;rea</cellbytelabel></td>
			<td colspan="5">[<%=area.getCodigo()%>] <%=area.getDescripcion()%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="45%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="3">Usado Por</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="3">Orden</cellbytelabel></td>
			<td width="25%">&nbsp;</td>
			<td width="3%">
<%
//if (SecMgr.checkAccess(session.getId(),"0"))
//{
%>
		<%=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
<%
//}
%>
			</td>
		</tr>
<%
al = CmnMgr.reverseRecords(iDet);
for (int i = 1; i <= iDet.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleCara det = (DetalleCara) iDet.get(key);
	String displayDetalle = "";
	if (det.getStatus() != null && det.getStatus().equalsIgnoreCase("D")) displayDetalle = " style=\"display:none\"";
%>
		<%=fb.hidden("status"+i,det.getStatus())%>
		<%=fb.hidden("key"+i,det.getKey())%>
		<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01" align="center"<%=displayDetalle%>>
			<td><%=fb.intBox("codigo"+i,det.getCodigo(),false,false,true,5)%></td>
			<td><%=fb.textBox("descripcion"+i,det.getDescripcion(),true,false,false,85)%></td>
			<td><%=fb.select("usado_por"+i,"M=MEDICO, E=ENFERMERA,T=TODOS",det.getUsadoPor(),false,false,0,"Text10",null,null,"","")%></td>
            <td><%=fb.intBox("orden"+i,det.getOrden(),false,false,false,5,2)%></td>
			<td>
                <a href="javascript:setCds(<%=det.getCodigo()%>)" class="Link02Bold">Centro de Servicios</a>&nbsp;|&nbsp;
                <a href="javascript:setSubCaract(<%=det.getCodigo()%>, '<%=det.getDescripcion()%>')" class="Link02Bold">Sub. Caract.</a>
            </td>
			<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeDetail("+i+")\"")%></td>
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
<script type="text/javascript">
<%
String tabLabel = "'Area'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Centro de Servicios','Características'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>
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
		area = new AreaCorporal();
		area.setCodigo(request.getParameter("id"));
		area.setDescripcion(request.getParameter("descripcion"));
		area.setUsadoPor(request.getParameter("usado_por"));
		area.setOrden(request.getParameter("orden"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add"))
		{
			ACMgr.add(area);
			id = ACMgr.getPkColValue("codigo");
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
			ACMgr.update(area);
		}
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("1"))
	{
		int size = Integer.parseInt(request.getParameter("size"));
		String itemRemoved = "";

		area = new AreaCorporal();
		area.setCodigo(request.getParameter("id"));
		area.getCds().clear();
		for (int i=1; i<=size; i++)
		{
			DetalleCara det = new DetalleCara();

			det.setCodigo(request.getParameter("codigo"+i));
			det.setDescripcion(request.getParameter("descripcion"+i));
			det.setObservacion(request.getParameter("observacion"+i));
			det.setSecOrden(request.getParameter("secOrden"+i));
			det.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = det.getKey();
			else
			{
				try
				{
					iCds.put(det.getKey(),det);
					area.addCds(det);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			vCds.remove(((DetalleCara) iCds.get(itemRemoved)).getCodigo());
			iCds.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&detLastLineNo="+detLastLineNo+"&cdsLastLineNo="+cdsLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&tab="+tab+"&id="+id+"&detLastLineNo="+detLastLineNo+"&cdsLastLineNo="+cdsLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ACMgr.addCds(area);
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("2"))
	{
		int size = Integer.parseInt(request.getParameter("size"));
		String itemRemoved = "";

		area = new AreaCorporal();
		area.setCodigo(request.getParameter("id"));
		area.getDetalle().clear();
		for (int i=1; i<=size; i++)
		{
			DetalleCara det = new DetalleCara();

			det.setCodigo(request.getParameter("codigo"+i));
			det.setDescripcion(request.getParameter("descripcion"+i));
			det.setStatus(request.getParameter("status"+i));
			det.setUsadoPor(request.getParameter("usado_por"+i));
			det.setOrden(request.getParameter("orden"+i));

			det.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = det.getKey();
				det.setStatus("D");//D=Delete action
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
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&detLastLineNo="+detLastLineNo+"&cdsLastLineNo="+cdsLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			DetalleCara det = new DetalleCara();

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

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tab="+tab+"&id="+id+"&detLastLineNo="+detLastLineNo+"&cdsLastLineNo="+cdsLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ACMgr.addDetalle(area);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (ACMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ACMgr.getErrMsg()%>');
<%
	if (tab.equals("0"))
	{
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/areacorporal_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/areacorporal_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/areacorporal_list.jsp';
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
} else throw new Exception(ACMgr.getErrMsg());
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