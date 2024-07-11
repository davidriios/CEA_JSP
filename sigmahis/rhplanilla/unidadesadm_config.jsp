<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="iWH" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vWH" scope="session" class="java.util.Vector"/>
<jsp:useBean id="htCtas" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCtas" scope="session" class="java.util.Vector"/>
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

ArrayList al= new ArrayList();
String sql="";
String fp = request.getParameter("fp");
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
int whLastLineNo = 0,ctaLastLineNo=0;
String key = "";
if (request.getParameter("whLastLineNo") != null) whLastLineNo = Integer.parseInt(request.getParameter("whLastLineNo"));
if (request.getParameter("ctaLastLineNo") != null) ctaLastLineNo = Integer.parseInt(request.getParameter("ctaLastLineNo"));
if (tab == null) tab = "0";
if (mode == null) mode = "add";
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		iWH.clear();
		vWH.clear();
		htCtas.clear();
		vCtas.clear();
	}
	else
	{
		if (id == null) throw new Exception("La Unidad Administratuva no es válido. Por favor intente nuevamente!");

		sql="select a.compania, a.codigo, a.descripcion, a.direccion, a.corregimiento, a.distrito, a.provincia, a.pais, a.telefono, a.extension , a.fax, nvl(a.email,'') as email, nvl(a.ue_codigo,'') as reporte , a.ue_compania, nvl(a.nivel,'') as nivel, a.area, a.estado, a.depto_preelab as cPrelacion,g.descripcion as nDescrip,c.NOMBRE_PAIS as paNombre, c.NOMBRE_PROVINCIA as pNombre, c.NOMBRE_DISTRITO as dNombre, c.NOMBRE_CORREGIMIENTO as cNombre,(select descripcion from tbl_sec_unidad_ejec where codigo = nvl(a.ue_codigo,a.codigo)) as nom, a.tipo_unidad_adm,nvl(a.cod_ref,'') as cod_ref from tbl_sec_unidad_ejec a, vw_sec_regional_location c, (select codigo, descripcion from tbl_sec_nivel_unidadej) g where a.nivel = g.codigo(+) and a.pais = c.CODIGO_PAIS(+) and a.provincia = c.CODIGO_PROVINCIA(+) and a.distrito = c.CODIGO_DISTRITO(+) and a.corregimiento = c.CODIGO_CORREGIMIENTO(+) and a.compania = "+(String) session.getAttribute("_companyId")+" and c.nivel(+) = 3  and a.codigo="+id;
		cdo = SQLMgr.getData(sql);
		if(change == null)
		{
			//----------------------------ALMACENES--------------------------------------
			iWH.clear();
			vWH.clear();
			htCtas.clear();
			vCtas.clear();
			sql = "select a.ua, a.almacen as codigo_almacen, a.compania, a.comments, (select descripcion from tbl_inv_almacen where compania=a.compania and codigo_almacen=a.almacen) as desc_almacen, (select nombre from tbl_sec_compania where codigo=a.compania) as compania_name from tbl_sec_ua_almacen a where a.ua="+id+" and a.compania="+(String) session.getAttribute("_companyId")+" order by 2";

			al = SQLMgr.getDataList(sql);
			whLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo2.addColValue("key",key);

				try
				{
					iWH.put(key, cdo2);
					vWH.addElement(cdo2.getColValue("compania")+"-"+cdo2.getColValue("codigo_almacen"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			//----------------------------fin almacen--------------------------------------

			sql = "select a.ua, a.compania, a.comments, a.cta1,a.cta2,a.cta3,a.cta4,a.cta5,a.cta6,a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 cuenta,(select descripcion from tbl_con_catalogo_gral where compania=a.compania and cta1=a.cta1 and cta2=a.cta2 and cta3=a.cta3 and cta4=a.cta4 and cta5=a.cta5 and cta6=a.cta6) as desc_cuenta, (select nombre from tbl_sec_compania where codigo=a.compania) as compania_name,to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion,a.usuario_creacion,a.id,status from tbl_con_ua_cuentas a where a.ua="+id+" and a.compania="+(String) session.getAttribute("_companyId")+" order by 2";

			al = SQLMgr.getDataList(sql);
			ctaLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo2.addColValue("key",key);

				try
				{
					htCtas.put(key, cdo2);
					vCtas.addElement(cdo2.getColValue("cuenta"));
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
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title="Mantenimiento de Unidades Administrativas - "+document.title;
function agregar(){abrir_ventana1('../admin/ubic_geografica_list.jsp?fp=unidadAdmin');}
function niveles(){abrir_ventana1('../rhplanilla/list_nivel.jsp');}
function reportar(){abrir_ventana1('../rhplanilla/list_reportar.jsp');}
function doAction()
{
<%
	if (request.getParameter("type") != null)
	{
		if (tab.equals("1"))
		{
%>
	showAlmacenList();
<%
		}
		else if (tab.equals("2"))
		{
%>
	showCuentaList();
<%
		}
	}
%>
}
function showAlmacenList(){abrir_ventana1('../common/check_almacen.jsp?fg=<%=fp%>&fp=ua_references&mode=<%=mode%>&id=<%=id%>&whLastLineNo=<%=whLastLineNo%>');}
function showCuentaList(){abrir_ventana1('../common/check_cuentas_rep.jsp?fg=<%=fp%>&fp=und&mode=<%=mode%>&id=<%=id%>');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder" width="100%"><div name="pagerror" id="pagerror" class="FieldError" style="visibility:hidden; display:none;">&nbsp;</div>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<table id="tbl_generales" width="100%" cellpadding="1" border="0" cellspacing="1" align="center">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("iWHSize",""+iWH.size())%>
<%=fb.hidden("ctaLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("htCtasSize",""+htCtas.size())%>

<tr>
	<td>&nbsp;</td>
</tr>
<tr class="TextRow02">
	<td>&nbsp;</td>
</tr>
 <tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="95%">Unidades Administrativas</td>

								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>


				<tr id="panel0">
					<td>
					<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
						<tr class="TextRow01">
							<td width="9%">C&oacute;digo</td>
							<td width="35%"><%=id%></td>
							<td width="21%">Nombre</td>
							<td width="35%"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,25,100)%>&nbsp;&nbsp;
							<cellbytelabel>Estado</cellbytelabel><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"))%></td>
							
							
						</tr>
						<tr class="TextRow01">
							<td>Nivel</td>
											<td><%=fb.intBox("nivel",cdo.getColValue("nivel"),false,false,true,10,2)%><%=fb.textBox("nDescrip",cdo.getColValue("nDescrip"),false,false,true,25)%><%=fb.button("enviar","...",true,false,null,null,"onClick=\"javascript:niveles();\"")%></td>
							<td>Reporta a</td>
							<td><%=fb.intBox("reporte",cdo.getColValue("reporte"),false,false,true,10,4)%><%=fb.textBox("nom",cdo.getColValue("nom"),false,false,true,25)%><%=fb.button("report","...",true,false,null,null,"onClick=\"javascript:reportar();\"")%></td>
						</tr>
						<tr class="TextRow01" >
							<td>Tel&eacute;fono</td>
							<td><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,false,false,30,13)%></td>
							<td>Extensi&oacute;n</td>
							<td><%=fb.textBox("extension",cdo.getColValue("extension"),false,false,false,10,6)%>&nbsp;&nbsp;Fax&nbsp;<%=fb.textBox("fax",cdo.getColValue("fax"),false,false,false,15,13)%></td>
						</tr>
						<tr class="TextRow01">
							<td>Ar&eacute;a</td>
							<td><%=fb.intBox("area",cdo.getColValue("area"),false,false,false,10,6)%></td>
							<td>Email</td>
							<td><%=fb.textBox("email",cdo.getColValue("email"),false,false,false,30,100)%></td>
						</tr>
						<tr class="TextRow01">
							<td>Direcci&oacute;n</td>
							<td><%=fb.textBox("direccion",cdo.getColValue("direccion"),true,false,false,30,200)%></td>
							<td>C&oacute;d. Depto. Preelaborada</td>
							<td><%=fb.textBox("cPrelacion",cdo.getColValue("cPrelacion"),false,false,false,10,5)%></td>
						</tr>
						<tr class="TextRow01">
							<td>Tipo Unidad Adm.</td>
							<td>
							<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_par_tipo_unidad_adm","tipo_unidad_adm",cdo.getColValue("tipo_unidad_adm"),false,false,0)%>
							</td>
							<td>Cod. REF EXTERNA</td>
							<td><%=fb.textBox("cod_ref",cdo.getColValue("cod_ref"),false,false,false,15,100)%></td>
						</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0" border="0">
						<tr class="TextPanel">
							<td width="95%">Ubicaci&oacute;n Geogr&aacute;fica</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
							<tr class="TextRow01">
								<td width="9%">Pa&iacute;s</td>
								<td width="40%"><%=fb.intBox("pais",cdo.getColValue("pais"),false,false,true,10,4)%><%=fb.textBox("paNombre",cdo.getColValue("paNombre"),false,false,true,25)%></td>
								<td width="11%">Provincia</td>
								<td width="40%"><%=fb.intBox("provincia",cdo.getColValue("provincia"),false,false,true,10,2)%><%=fb.textBox("pNombre",cdo.getColValue("pNombre"),false,false,true,25)%></td>
							</tr>
							<tr class="TextRow01">
								<td>Distrito</td>
								<td><%=fb.intBox("distrito",cdo.getColValue("distrito"),false,false,true,10,3)%><%=fb.textBox("dNombre",cdo.getColValue("dNombre"),false,false,true,25)%></td>
									<td>Corregimiento</td>
								<td><%=fb.intBox("corregimiento",cdo.getColValue("corregimiento"),false,false,true,10,4)%><%=fb.textBox("cNombre",cdo.getColValue("cNombre"),false,false,true,25)%><%=fb.button("enviar","...",true,false,null,null,"onClick=\"javascript:agregar();\"")%></td>
							</tr>
						</table>

					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr class="TextRow02">
		<td colspan="4" align="right">
			Opciones de Guardar:
			<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro
			<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
			<%=fb.radio("saveOption","C",false,false,false)%>Cerrar
			<%=fb.submit("save","Guardar",true,false)%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	<tr>
<%=fb.formEnd(true)%>
</table>
<!-- TAB0 DIV END HERE-->
</div>
<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("iWHSize",""+iWH.size())%>
<%=fb.hidden("ctaLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("htCtasSize",""+htCtas.size())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(60)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Unidad Administrativa</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus60" style="display:none">+</label><label id="minus60">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel60">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="10%" align="right">C&oacute;digo</td>
							<td width="35%"><%=cdo.getColValue("codigo")%></td>
							<td width="15%" align="right">Descripci&oacute;n</td>
							<td width="35%"><%=cdo.getColValue("descripcion")%></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(61)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Almacenes</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus61" style="display:none">+</label><label id="minus61">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel61">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td colspan="2">Almac&eacute;n</td>
							<td width="47%" rowspan="2">Comentarios</td>
							<td width="3%" rowspan="2"><%=fb.submit("addWh","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Almacenes")%></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="10%">C&oacute;digo</td>
							<td width="50%">Descripci&oacute;n</td>
						</tr>
<%
al = CmnMgr.reverseRecords(iWH);
for (int i=1; i<=iWH.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject cdo2 = (CommonDataObject) iWH.get(key);
%>
						<%=fb.hidden("key"+i,cdo2.getColValue("key"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("compania"+i,cdo2.getColValue("compania"))%>
						<%=fb.hidden("compania_name"+i,cdo2.getColValue("compania_name"))%>
						<%=fb.hidden("codigo_almacen"+i,cdo2.getColValue("codigo_almacen"))%>
						<%=fb.hidden("desc_almacen"+i,cdo2.getColValue("desc_almacen"))%>

						<tr class="TextRow01">
							<td><%=cdo2.getColValue("codigo_almacen")%></td>
							<td><%=cdo2.getColValue("desc_almacen")%></td>
							<td><%=fb.textarea("comments"+i,cdo2.getColValue("comments"),false,false,false,50,2,2000)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
	fb.appendJsValidation("if(error>0)doAction();");

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
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->


				</table>

<!-- TAB1 DIV END HERE-->
</div>
<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("iWHSize",""+iWH.size())%>
<%=fb.hidden("ctaLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("htCtasSize",""+htCtas.size())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(60)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Unidad Administrativa</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus60" style="display:none">+</label><label id="minus60">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel60">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="10%" align="right">C&oacute;digo</td>
							<td width="35%"><%=cdo.getColValue("codigo")%></td>
							<td width="15%" align="right">Descripci&oacute;n</td>
							<td width="35%"><%=cdo.getColValue("descripcion")%></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(61)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Cuentas</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus61" style="display:none">+</label><label id="minus61">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel61">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td colspan="2">Cuenta</td>
							<td width="37%" rowspan="2">Comentarios</td>
							<td width="10%" rowspan="2">Estado</td>
							<td width="3%" rowspan="2"><%=fb.submit("addCta","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Cuentas Para Presupuesto")%></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="10%">C&oacute;digo</td>
							<td width="50%">Descripci&oacute;n</td>
						</tr>
<%
al = CmnMgr.reverseRecords(htCtas);
for (int i=1; i<=htCtas.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject cdo2 = (CommonDataObject) htCtas.get(key);
%>
						<%=fb.hidden("key"+i,cdo2.getColValue("key"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("compania"+i,cdo2.getColValue("compania"))%>
						<%=fb.hidden("cta1"+i,cdo2.getColValue("cta1"))%>
						<%=fb.hidden("cta2"+i,cdo2.getColValue("cta2"))%>
						<%=fb.hidden("cta3"+i,cdo2.getColValue("cta3"))%>
						<%=fb.hidden("cta4"+i,cdo2.getColValue("cta4"))%>
						<%=fb.hidden("cta5"+i,cdo2.getColValue("cta5"))%>
						<%=fb.hidden("cta6"+i,cdo2.getColValue("cta6"))%>
						<%=fb.hidden("desc_cuenta"+i,cdo2.getColValue("desc_cuenta"))%>
						<%=fb.hidden("cuenta"+i,cdo2.getColValue("cuenta"))%>
						<%=fb.hidden("fecha_creacion"+i,cdo2.getColValue("fecha_creacion"))%>
						<%=fb.hidden("usuario_creacion"+i,cdo2.getColValue("usuario_creacion"))%>
						<%=fb.hidden("id"+i,cdo2.getColValue("id"))%>

						<tr class="TextRow01">
							<td width="20%"><%=cdo2.getColValue("cuenta")%></td>
							<td width="30%"><%=cdo2.getColValue("desc_cuenta")%></td>
							<td width="30%"><%=fb.textarea("comments"+i,cdo2.getColValue("comments"),false,false,false,50,2,2000)%></td>
							<td width="15%"> <%=fb.select("status"+i,"A=ACTIVO,I=INACTIVO",cdo2.getColValue("status"),false,false,0,"Text10",null,"")%> </td>
							<td width="5%" align="center"><%=fb.submit("rem"+i,"X",true,(cdo2.getColValue("id")!=null && !cdo2.getColValue("id").trim().equals("0")),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
	fb.appendJsValidation("if(error>0)doAction();");

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
						<%=fb.submit("save","Guardar",true,false)%>
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
String tabLabel = "'Generales'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Almacenes'";
//if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Almacenes','Cuentas'";
//else if(!tab.equals("0")) tab = ""+(Integer.parseInt(tab)-2);

%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>


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
	if(tab.trim().equals("0")){
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_sec_unidad_ejec");
	cdo.addColValue("descripcion",request.getParameter("descripcion"));
	cdo.addColValue("direccion",request.getParameter("direccion"));

	if (request.getParameter("corregimiento") != null && !request.getParameter("corregimiento").trim().equals("") && !request.getParameter("corregimiento").trim().equals("0"))
	{
	cdo.addColValue("corregimiento",request.getParameter("corregimiento"));
	if (request.getParameter("distrito") != null && !request.getParameter("distrito").trim().equals("") && !request.getParameter("distrito").trim().equals("0"))
	cdo.addColValue("distrito",request.getParameter("distrito"));
	if (request.getParameter("provincia") != null && !request.getParameter("provincia").trim().equals("") && !request.getParameter("provincia").trim().equals("0"))
	cdo.addColValue("provincia",request.getParameter("provincia"));
	if (request.getParameter("pais") != null && !request.getParameter("pais").trim().equals("") && !request.getParameter("pais").trim().equals("0"))
	cdo.addColValue("pais",request.getParameter("pais"));
	}
	cdo.addColValue("telefono",request.getParameter("telefono"));
	cdo.addColValue("extension",request.getParameter("extension"));
	cdo.addColValue("fax",request.getParameter("fax"));
	cdo.addColValue("estado",request.getParameter("estado"));
	cdo.addColValue("email",request.getParameter("email"));
	if (request.getParameter("reporte") != null)
	cdo.addColValue("ue_codigo",request.getParameter("reporte"));
	if (request.getParameter("nivel") != null)
	cdo.addColValue("nivel",request.getParameter("nivel"));
	cdo.addColValue("area",request.getParameter("area"));
	cdo.addColValue("depto_preelab",request.getParameter("cPrelacion"));
	cdo.addColValue("tipo_unidad_adm",request.getParameter("tipo_unidad_adm"));
	cdo.addColValue("cod_ref",request.getParameter("cod_ref"));

	if (request.getParameter("nivel").equals("3"))
		cdo.setCreateXML(true);
	cdo.setFileName("itemUnidad.xml");
	cdo.setOptValueColumn("ue_codigo");
	cdo.setOptLabelColumn("descripcion");
	cdo.setKeyColumn("compania");
	cdo.setXmlWhereClause("");

	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addColValue("ue_compania",(String) session.getAttribute("_companyId"));
		//cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");

		SQLMgr.insert(cdo);
		id = SQLMgr.getPkColValue("codigo");
	}
	else
	{
			cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and codigo="+request.getParameter("id"));

		SQLMgr.update(cdo);
	}
}//tab 0
else if (tab.equals("1")) //Almacenes
	{
		int size = 0;
		if (request.getParameter("iWHSize") != null) size = Integer.parseInt(request.getParameter("iWHSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo2 = new CommonDataObject();

			cdo2.setTableName("tbl_sec_ua_almacen");
			cdo2.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and ua="+id);

			cdo2.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo2.addColValue("ua",id);
			cdo2.addColValue("codigo_almacen",request.getParameter("codigo_almacen"+i));
			cdo2.addColValue("almacen",request.getParameter("codigo_almacen"+i));
			cdo2.addColValue("key",request.getParameter("key"+i));
			cdo2.addColValue("compania_name",request.getParameter("compania_name"+i));
			cdo2.addColValue("desc_almacen",request.getParameter("desc_almacen"+i));
			cdo2.addColValue("comments",request.getParameter("comments"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo2.getColValue("key");
			else
			{
				try
				{
					iWH.put(cdo2.getColValue("key"),cdo2);
					al.add(cdo2);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			vWH.remove(((CommonDataObject) iWH.get(itemRemoved)).getColValue("compania")+"-"+((CommonDataObject) iWH.get(itemRemoved)).getColValue("codigo_almacen"));
			iWH.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&tab=1&mode="+mode+"&id="+id+"&whLastLineNo="+whLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&type=1&tab=1&mode="+mode+"&id="+id+"&whLastLineNo="+whLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo2 = new CommonDataObject();

			cdo2.setTableName("tbl_sec_ua_almacen");
			cdo2.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and ua="+id);

			al.add(cdo2);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}
	//***************************************************************************
	else if (tab.equals("2")) //Cuentas Para Presupuesto
	{
		int size = 0;
		if (request.getParameter("htCtasSize") != null) size = Integer.parseInt(request.getParameter("htCtasSize"));
		String itemRemoved = "";

		al.clear();
		htCtas.clear();
		vCtas.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo2 = new CommonDataObject();

			cdo2.setTableName("tbl_con_ua_cuentas");
			cdo2.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and ua="+id);

			cdo2.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo2.addColValue("ua",id);
			cdo2.addColValue("cta1",request.getParameter("cta1"+i));
			cdo2.addColValue("cta2",request.getParameter("cta2"+i));
			cdo2.addColValue("cta3",request.getParameter("cta3"+i));
			cdo2.addColValue("cta4",request.getParameter("cta4"+i));
			cdo2.addColValue("cta5",request.getParameter("cta5"+i));
			cdo2.addColValue("cta6",request.getParameter("cta6"+i));
			cdo2.addColValue("key",request.getParameter("key"+i));
			//cdo2.addColValue("compania_name",request.getParameter("compania_name"+i));
			cdo2.addColValue("desc_cuenta",request.getParameter("desc_cuenta"+i));
			cdo2.addColValue("comments",request.getParameter("comments"+i));
			cdo2.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));
			cdo2.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
			cdo2.addColValue("fecha_modificacion",cDateTime);
			cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo2.addColValue("cuenta",request.getParameter("cuenta"+i));
			cdo2.addColValue("status",request.getParameter("status"+i));

			//if (request.getParameter("id"+i) != null && !request.getParameter("id"+i).trim().equals("")&& !request.getParameter("id"+i).trim().equals("0"))
			cdo2.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and ua="+id);
			cdo2.setAutoIncCol("id");


			//else cdo2.addColValue("id",request.getParameter("id"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo2.getColValue("key");
			else
			{
				try
				{
					htCtas.put(cdo2.getColValue("key"),cdo2);
					al.add(cdo2);
					vCtas.add(request.getParameter("cuenta"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&tab=2&mode="+mode+"&id="+id+"&whLastLineNo="+whLastLineNo+"&ctaLastLineNo="+ctaLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&type=1&tab=2&mode="+mode+"&id="+id+"&whLastLineNo="+whLastLineNo+"&ctaLastLineNo="+ctaLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo2 = new CommonDataObject();

			cdo2.setTableName("tbl_con_ua_cuentas");
			cdo2.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and ua="+id);

			al.add(cdo2);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/unidadesadm_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/unidadesadm_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/unidadesadm_list.jsp?fp=<%=fp%>';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&mode=edit&tab=<%=tab%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>