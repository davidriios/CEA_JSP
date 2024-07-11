<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.StringTokenizer"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="IXml" scope="page" class="issi.admin.XMLCreator"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/> 
<jsp:useBean id="iIns" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vIns" scope="session" class="java.util.Vector"/> 
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
IXml.setConnection(ConMgr);

CommonDataObject proc = new CommonDataObject();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String codProc = request.getParameter("codProc");
String change = request.getParameter("change");  
String fechaCita = request.getParameter("fechaCita");  
String codCita = request.getParameter("codCita");  
 
if (tab == null) tab = "0";
if (mode == null) mode = "add"; 
if (codProc == null) codProc = ""; 
if (fechaCita == null) fechaCita = ""; 
if (id == null) id = ""; 
if (codCita == null) codCita = ""; 
codProc = codProc.replace("~",",");

String descAl ="";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
	StringTokenizer st = new StringTokenizer(codProc,",");
		while (st.hasMoreTokens()){
			if((id==null || id.equals(""))){
				id = st.nextToken();
			} else break;
		}
	if (!id.equalsIgnoreCase(""))
	{
		 
		proc.addColValue("codigo","");
	  
		sql = "select a.codigo, a.estado, a.tipo_categoria, a.observacion, a.descripcion, decode(a.precio,null,' ',a.precio) as precio, decode(a.costo_ref,null,' ',a.costo_ref) as costo_ref,decode(a.costo,null,' ',a.costo) as costo, decode(a.precio_oferta,null,' ',a.precio_oferta) as precio_oferta, decode(a.precio2,null,' ',a.precio2) as precio2, decode(a.costo2,null,' ',a.costo2) as costo2, decode(a.precio_oferta2,null,' ',a.precio_oferta2) as precio_oferta2, decode(a.precio3,null,' ',a.precio3) as precio3, decode(a.costo3,null,' ',a.costo3) as costo3, decode(a.precio_oferta3,null,' ',a.precio_oferta3) as precio_oferta3, decode(a.precio4,null,' ',a.precio4) as precio4, decode(a.costo4,null,' ',a.costo4) as costo4, decode(a.precio_oferta4,null,' ',a.precio_oferta4) as precio_oferta4, decode(a.precio5,null,' ',a.precio5) as precio5, decode(a.costo5,null,' ',a.costo5) as costo5, decode(a.precio_oferta5,null,' ',a.precio_oferta5) as precio_oferta5, a.tiempo_estimado, a.unidad_tiempo, a.cod_cds, a.cod_cds2, a.cod_cds3, a.cod_cds4, a.cod_cds5, (select nombre from tbl_cds_tipo_categoria where codigo=a.tipo_categoria) as tipo_categoria_desc, (select descripcion from tbl_cds_centro_servicio where codigo=a.cod_cds) as desc_cds, (select descripcion from tbl_cds_centro_servicio where codigo=a.cod_cds2) as desc_cds2, (select descripcion from tbl_cds_centro_servicio where codigo=a.cod_cds3) as desc_cds3, (select descripcion from tbl_cds_centro_servicio where codigo=a.cod_cds4) as desc_cds4, (select descripcion from tbl_cds_centro_servicio where codigo=a.cod_cds5) as desc_cds5, tipo_maletin_anestesia, a.nombre_corto from tbl_cds_procedimiento a where a.codigo = '"+id+"'" ;
		proc = SQLMgr.getData(sql);

		if (change == null)
		{
			iIns.clear();
			vIns.clear();

			sql = "select art_familia,art_clase,cod_articulo as articulo,descripcion,cantidad,cod_articulo as code, paquete,precio_venta,costo,nvl(existe,0) as existe from ( /* SELECT a.art_familia, a.art_clase, a.articulo, b.descripcion, a.cantidad, a.articulo as code, a.paquete, to_char( nvl(b.precio_venta,0), '9,999999.99' ) precio_venta, (select to_char(nvl(precio,0), '9,999999.99') from tbl_inv_inventario where codigo_almacen = (select min(codigo_almacen) from tbl_inv_inventario  where compania = b.compania and cod_articulo = b.cod_articulo) and compania = b.compania and cod_articulo = b.cod_articulo ) costo FROM tbl_cds_insumo_x_proc a, tbl_inv_articulo b WHERE a.articulo=b.cod_articulo and a.compania=b.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.cod_proced='"+id+"' union all*/  select b.art_familia,b.art_clase,c.descripcion,(nvl(b.entrega,0)+ nvl(b.adicion,0)-nvl(b.devolucion,0)) as cantidad,b.cod_articulo,b.paquete,to_char(nvl(c.precio_venta,0),'9,999999.99' ) as precio_venta,(select to_char(nvl(precio,0), '9,999999.99') from tbl_inv_inventario where codigo_almacen =nvl(b.almacen,a.codigo_almacen) and cod_articulo = b.cod_articulo and compania = a.compania ) as costo,(select count(*) from tbl_cds_insumo_x_proc x WHERE x.articulo=b.cod_articulo and x.compania="+(String) session.getAttribute("_companyId")+" and x.cod_proced='"+id+"' ) as existe from tbl_cdc_solicitud_enc a, tbl_cdc_solicitud_det b, tbl_inv_articulo c where a.cita_codigo = b.cita_codigo and to_date(to_char(a.cita_fecha_reg, 'dd/mm/yyyy'),'dd/mm/yyyy') = to_date(to_char(b.cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') and a.secuencia = b.secuencia and a.tipo_solicitud = 'Q' and a.estado='E' and b.cod_articulo = c.cod_articulo and b.compania = c.compania  and a.cita_codigo = " + codCita + " and to_date(to_char(a.cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy') and a.compania = " + (String) session.getAttribute("_companyId") + " and (nvl(b.entrega,0)+ nvl(b.adicion,0)-nvl(b.devolucion,0))<> 0  order by c.descripcion, b.art_familia, b.art_clase,b.cod_articulo ) order by 4 ";

			al  = SQLMgr.getDataList(sql);
			
			 if(al.size() ==0){descAl=" LA SOLICITUD NO HA SIDO CERRADA. ";
			sql = " SELECT a.art_familia, a.art_clase, a.articulo, b.descripcion, a.cantidad, a.articulo as code, a.paquete, to_char( nvl(b.precio_venta,0), '9,999999.99' ) as precio_venta, (select to_char(nvl(precio,0), '9,999999.99') from tbl_inv_inventario where codigo_almacen = (select min(codigo_almacen) from tbl_inv_inventario  where compania = b.compania and cod_articulo = b.cod_articulo) and compania = b.compania and cod_articulo = b.cod_articulo ) costo, 1 as existe  FROM tbl_cds_insumo_x_proc a,tbl_inv_articulo b WHERE a.articulo=b.cod_articulo and a.compania=b.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.cod_proced='"+id+"' order by 4 ";
			al  = SQLMgr.getDataList(sql);
			
			}
 
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				if(cdo.getColValue("existe").trim().equals("0"))cdo.setAction("I");
				else cdo.setAction("U");
				try
				{
					iIns.put(cdo.getKey(), cdo);
					vIns.addElement(cdo.getColValue("code"));
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
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Procedimiento -  Edición - '+document.title;
function doAction(){}
function showArticuloList()
{
	abrir_ventana1('../common/check_articulo.jsp?fp=procedimiento&mode=<%=mode%>&id=<%=id%>');
}
function showReporte(opt){
  <%if(mode.equalsIgnoreCase("edit")){%>
	var cpt = '<%=id%>';
	if(cpt != '') {
    if(!opt) abrir_ventana('../inventario/print_cdc_insumos.jsp?cpt='+cpt);
    else if(opt==1) abrir_ventana('../inventario/print_cdc_insumos.jsp?cost=Y&cpt='+cpt);
    else if(opt==2) abrir_ventana('../inventario/print_cdc_insumos.jsp?price=Y&cpt='+cpt);
  }
  <%}%>
}
function changeCod(codigo){var cod = document.form0.codigo.value;	window.location = '../admision/procedimientos_config_insumos.jsp?fp=citas_cons&codProc=<%=codProc%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&id='+cod;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISIÓN - MANTENIMIENTO - PROCEDIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
			<%if(mode.equalsIgnoreCase("edit")){%>
		<tr class="TextRow02">
			<td align="right">
          <%//=fb.button("report","Generar Reporte",true,false,null,null,"onClick=\"javascript:showReporte()\"")%>
          <button type="button" onclick="javascript:showReporte()" class="CellbyteBtn">Generar Reporte</button>
          <button type="button" onclick="javascript:showReporte(1)" class="CellbyteBtn">Con Costo</button>
          <button type="button" onclick="javascript:showReporte(2)" class="CellbyteBtn">Con Precio</button>
      </td>	
		</tr>	
			<%}%>
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
 <!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("insSize",""+iIns.size())%>
<%=fb.hidden("codProc",codProc)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("codCita",codCita)%>

				<tr class="TextRow01">
							<td><%//=sql%><cellbytelabel id="2">CPT<%//=fb.textBox("codigo",id,false,false,true,15,null,null,"")%>
							<%=fb.select("codigo",codProc,id,false,false,0,"",null,"onChange=\"javascript:changeCod(this.value);\"")%>
							<cellbytelabel id="3">Categor&iacute;a</cellbytelabel>
							<%=fb.select(ConMgr.getConnection(),"select codigo, nombre from tbl_cds_tipo_categoria","tipo_categoria",proc.getColValue("tipo_categoria"),false,true,0,null,null,null,null,"S")%>
							<cellbytelabel id="9">Espa&ntilde;o</cellbytelabel>l <%=fb.textBox("observacion",proc.getColValue("observacion"),false,false,true,50)%>
							<cellbytelabel id="10">Ingl&eacute;s</cellbytelabel> <%=fb.textBox("descripcion",proc.getColValue("descripcion"),false,false,true,50)%>
							<br>
							<label class="RedTextBold">**Articulos en color rojo ya estan en la configuracion de Insumos por procedimiento** <br><%=descAl%></label>
							</td>
						</tr>
				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						
						
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="19">Insumos del Procedimiento </cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel id="20">C&oacute;digo del Insumo</cellbytelabel></td>
							<td width="50%"><cellbytelabel id="21">Descripci&oacute;n</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="22">Cantidad</cellbytelabel></td>
							<td width="9%"><cellbytelabel id="22">Precio</cellbytelabel></td>
							<td width="9%"><cellbytelabel id="22">Costo</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="36">Paquete?</cellbytelabel></td>
							<td width="5%"><%//=fb.submit("btnaddIns","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Insumos")%></td>
						</tr>
						<%
						al = CmnMgr.reverseRecords(iIns);
						double totPrecioVenta  = 0, totCosto = 0;
						for (int i=0; i<iIns.size(); i++)
						{
							key=al.get(i).toString();
							CommonDataObject cdo = (CommonDataObject) iIns.get(key);
							
							totPrecioVenta += Double.parseDouble(cdo.getColValue("precio_venta","0"));
							totCosto += Double.parseDouble(cdo.getColValue("costo","0")); 
							String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
						%>
						<%=fb.hidden("code"+i,cdo.getColValue("code"))%>
						<%=fb.hidden("familyCode"+i,cdo.getColValue("art_familia"))%>
						<%=fb.hidden("classCode"+i,cdo.getColValue("art_clase"))%>
						<%=fb.hidden("itemCode"+i,cdo.getColValue("articulo"))%>
						<%=fb.hidden("item"+i,cdo.getColValue("descripcion"))%>
						<%=fb.hidden("precio_venta"+i,cdo.getColValue("precio_venta"))%>
						<%=fb.hidden("costo"+i,cdo.getColValue("costo"))%>
						<%=fb.hidden("existe"+i,cdo.getColValue("existe"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						
						<tr class="TextRow01" <%=style%>> 
						
							<td> <%=cdo.getAction()%><%=cdo.getColValue("art_familia")%>-<%=cdo.getColValue("art_clase")%>-<%=cdo.getColValue("code")%></td>
							<td <%if(!cdo.getColValue("existe").trim().equals("0")){%>class="RedTextBold"<%}%>><%=cdo.getColValue("descripcion")%></td>
							<td align="center"><%=fb.intBox("cantidad"+i,cdo.getColValue("cantidad"),false,false,false,5,4)%></td>
							<td align="center"><b><%=cdo.getColValue("precio_venta")%></b></td>
							<td align="center"><b><%=cdo.getColValue("costo")%></b></td>
							<td align="center"><%=fb.checkbox("paquete"+i,cdo.getColValue("paquete"),(cdo.getColValue("paquete")!=null && cdo.getColValue("paquete").equals("S")?true:false),false)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
						<%
						}
						fb.appendJsValidation("if(error>0)doAction();");
						%>
						<tr class="TextHeader02">
              <td align="right" colspan="3">Total</td>
              <td align="center"><%=CmnMgr.getFormattedDecimal(totPrecioVenta)%></td>
              <td align="center"><%=CmnMgr.getFormattedDecimal(totCosto)%></td>
              <td align="right" colspan="2"></td>
						</tr>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="18">Cerrar</cellbytelabel>
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

<script type="text/javascript">
<%
if (mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Insumos'),0,'100%','');
<%
}
else
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Insumos'),<%=tab%>,'100%','');
<%
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
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	if (tab.equals("0")) //INSUMOS
	{
		int size = 0;
		if (request.getParameter("insSize") != null) size = Integer.parseInt(request.getParameter("insSize"));
		String itemRemoved = "";

		al.clear();
		iIns.clear();
		vIns.clear();
		for (int i=0; i<size; i++)
		{
				CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_insumo_x_proc");
			cdo.setWhereClause("cod_proced='"+id+"'");
			cdo.setAutoIncWhereClause("cod_proced='"+id+"'");
			cdo.addColValue("cod_proced",id);
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("art_familia",request.getParameter("familyCode"+i));

			cdo.addColValue("art_clase",request.getParameter("classCode"+i));
			cdo.addColValue("articulo",request.getParameter("itemCode"+i));
			cdo.addColValue("descripcion",request.getParameter("item"+i));
			cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
			cdo.addColValue("precio_venta",request.getParameter("precio_venta"+i));
			cdo.addColValue("costo",request.getParameter("costo"+i));
			cdo.addColValue("existe",request.getParameter("existe"+i)); 			
			
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("code",request.getParameter("code"+i));
			if(request.getParameter("paquete"+i)!=null) cdo.addColValue("paquete", "S");
			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getColValue("articulo");
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X")&&!cdo.getAction().equalsIgnoreCase("D"))
			{
				try
				{
					iIns.put(cdo.getKey(),cdo);
					vIns.add(cdo.getColValue("articulo"));
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
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=0&mode="+mode+"&id="+id+"&codCita="+codCita+"&fechaCita="+fechaCita+"&codProc="+codProc);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_insumo_x_proc");
			cdo.setWhereClause("cod_proced='"+id+"'");
			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode=edit&id="+id+"&tab="+tab);
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	} //END TAB 0
	
%>
<html>
<head>
<script language="javascript" src="../common/header_param_min.jsp"></script>
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
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/procedimientos_list.jsp"))
		{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/procedimientos_list.jsp")%>';
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&codProc=<%=codProc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>