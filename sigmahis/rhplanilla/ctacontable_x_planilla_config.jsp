<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.CtaPlanilla"%>
<%@ page import="issi.rhplanilla.CtaPlanillaDet"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="java.util.Vector" buffer="16kb" autoFlush="true"%>
<jsp:useBean id="ConMgr"    scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr"    scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet"   scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr"    scope="page"    class="issi.admin.CommonMgr" />
<jsp:useBean id="fb"        scope="page"    class="issi.admin.FormBean" />
<jsp:useBean id="CtaMgr"    scope="session" class="issi.rhplanilla.CtaPlanillaMgr"/>
<jsp:useBean id="htcta"     scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vctunidad" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CtaMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CtaPlanilla ctasp= new CtaPlanilla();
ArrayList al= new ArrayList();	
String sql="";
String mode = request.getParameter("mode");
String id   = request.getParameter("id"); 
String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String cta4 = request.getParameter("cta4");
String cta5 = request.getParameter("cta5");
String cta6 = request.getParameter("cta6");
String planillaCode= request.getParameter("cod");
String conceptoCode = request.getParameter("conceptoCode");
String lados = request.getParameter("lados");
String tipos= request.getParameter("tipos");
String uni = request.getParameter("uni"); 
String key= "";
String change= request.getParameter("change");
int ctaLastLine=0;
boolean viewMode = false;
if(request.getParameter("ctaLastLine")!= null && !request.getParameter("ctaLastLine").equals(""))
ctaLastLine=Integer.parseInt(request.getParameter("ctaLastLine"));
else ctaLastLine=0;
if (mode == null) mode = "add";
if (uni == null) uni = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		htcta.clear();
	}
	else
	{
 	
 	sql = "select a.cod_compania as Compania, a.cod_planilla as planillaId, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.lado, a.movimiento, a.cod_concepto as conceptoId, a.tipo, a.fecha_creacion, a.usuario_creacion, a.fecha_mod, a.usuario_mod, a.unidad_adm as unidadAdminId, b.nombre as planillaName, decode(a.tipo,'G',nvl((select d.descripcion from tbl_con_catalogo_gral d where a.cta1=d.cta1 and a.cta2=d.cta2 and a.cta3=d.cta3 and a.cta4=d.cta4 and a.cta5=d.cta5 and a.cta6=d.cta6 and a.cod_compania= d.compania),' '),' ') as cuentaName, decode(a.tipo,'G','',(select e.descripcion from tbl_sec_unidad_ejec e where a.cod_compania=e.compania and a.unidad_adm=e.codigo)) as unidadAdminName,decode(a.tipo,'G',(select c.descripcion from tbl_pla_cuenta_concepto c where a.cod_concepto=c.cod_concepto and a.cod_compania = c.cod_compania),' ')as conceptoName ,a.id from tbl_pla_cuenta_planilla a, tbl_pla_planilla b where a.cod_planilla=b.cod_planilla and a.cod_compania=b.compania and a.cod_compania="+(String) session.getAttribute("_companyId")+" and id="+id;
	
 	
		ctasp = (CtaPlanilla) sbb.getSingleRowBean(ConMgr.getConnection(), sql, CtaPlanilla.class);
		System.out.println("SQL =========="+sql);
		
		if(change==null)
		{
		sql="select a.cod_compania as compania, a.cod_planilla, a.cta1 as ctas1, a.cta2 as ctas2, a.cta3 as ctas3, a.cta4 as ctas4, a.cta5 as ctas5, a.cta6 as ctas6, a.lado, a.cod_concepto as conceptoId, a.unidad_adm as unidadAdminId, a.ucta1, a.ucta2, a.ucta3, a.ucta4, a.ucta5, a.ucta6, to_char(a.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(a.fecha_mod,'dd/mm/yyyy') as fechaModif, b.nombre, c.descripcion as conceptoName, d.descripcion as unidadAdminName, e.descripcion as nameCuenta,a.id  from tbl_pla_cuenta_planilla_det a, tbl_pla_planilla b, tbl_pla_cuenta_concepto c, tbl_sec_unidad_ejec d, tbl_con_catalogo_gral e where a.cod_planilla=b.cod_planilla(+) and a.cod_compania=b.compania(+) and a.cod_concepto=c.cod_concepto(+)  and a.cod_compania = c.cod_compania(+) and a.cod_compania=d.compania and a.unidad_adm=d.codigo(+) and a.ucta1 = e.cta1 and a.ucta2 = e.cta2 and a.ucta3 = e.cta3 and a.ucta4 = e.cta4 and a.ucta5 = e.cta5 and a.ucta6 = e.cta6 and a.cod_compania = e.compania and  a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.id_ref = "+id;	 
			
		al = sbb.getBeanList(ConMgr.getConnection(), sql, CtaPlanillaDet.class);  
		System.out.println("SQL DET=========="+sql);
		htcta.clear();
		
		  
		ctaLastLine=al.size();
		for (int i=1; i<=al.size(); i++)
		{
		//CtaPlanilla ctaht= (CtaPlanilla) al.get(i-1);
		
		if (i < 10) key = "00" + i;
		else if (i < 100) key = "0" + i;
		else key = "" + i;
		//ctaht.setKey(key);

		//htcta.put(key, ctaht);
		htcta.put(key,al.get(i-1));
		//vctunidad.addElement(ctasp.getUnidadAdminId());
		ctaLastLine = i;
		
		}  	//End For	
		
		}
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Cuentas Contables por Planilla - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Cuentas Contables por Planilla - Editar - "+document.title;
<%}%>
function conceptosPlan()
{
var tipo= document.form1.tipo.value;
var planilla = document.form1.planillaId.value;
if(tipo=='G'){if(planilla!='')abrir_ventana1('../rhplanilla/list_conceptos.jsp?fp=ctaContaPlanillaEnc');else CBMSG.warning('Seleccione el tipo de Planilla!');}else CBMSG.warning('Para tipo Detallado no es necesario Agregar Concepto!');
}
function cuentasss()
{
var tipo= document.form1.tipo.value;
if(tipo=='G')abrir_ventana1('../common/search_catalogo_gral.jsp?fp=ctaContaPlanilla');else CBMSG.warning('Para tipo Detallado no es necesario Agregar Cuenta!');
}
function unidadAdm()
{
var tipo= document.form1.tipo.value;
if(tipo=='A')abrir_ventana1('../rhplanilla/list_seccion.jsp?fp=ctaContaPlanilla');else CBMSG.warning('Para tipo General no es necesario Agregar Unidad!');
}

function chkUnidad(){
	var planilla = document.form1.planillaId.value;
	var unidad = document.form1.unidadAdminId.value;
	if(hasDBData('<%=request.getContextPath()%>', 'tbl_pla_cuenta_planilla', 'cod_compania = <%=(String) session.getAttribute("_companyId")%> and cod_planilla = '+planilla +' and unidad_adm = '+unidad)){
		CBMSG.alert('Esta planilla ya tiene registros para esta unidad!');
		document.form1.unidadAdminId.value = '';
		document.form1.unidadAdminName.value = '';
	}
}

function chkPlanilla(){
	var planilla = document.form1.planillaId.value; 
	var tipo = document.form1.tipo.value; 
	var conceptoId = document.form1.conceptoId.value;
	if(tipo=='G' && planilla!=''&&conceptoId!='')
	{
		if(hasDBData('<%=request.getContextPath()%>', 'tbl_pla_cuenta_planilla', 'cod_compania = <%=(String) session.getAttribute("_companyId")%> and cod_planilla = '+planilla+' and tipo= \'G\' and cod_concepto='+conceptoId))
		{
			CBMSG.alert('Esta planilla ya tiene registros para el Concepto Seleccionado!');
			//document.form1.planillaId.value = ''; 
			document.form1.conceptoId.value = '';
			document.form1.conceptoName.value=""; 
		}
	}
}
function clearConcepto(){document.form1.conceptoId.value = '';document.form1.conceptoName.value = '';}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,100);}
function setCampos()
{
	
	var tipo= document.form1.tipo.value;
	if(tipo=='G')
	{
	chkPlanilla();
	document.form1.unidadAdminId.value="";
	document.form1.unidadAdminName.value=""; 
	document.form1.btnUnidad.disabled=true;
	document.form1.btnConcepto.disabled=false;
	document.form1.btnCtas.disabled=false;
	window.frames['itemFrame'].ctaDet.addCol.disabled=true;	
	}
	else
	{
		document.form1.conceptoId.value="";
		document.form1.conceptoName.value=""; 
		if('<%=htcta.size()%>'=='0'){document.form1.btnUnidad.disabled=false;}else document.form1.btnUnidad.disabled=true;
		document.form1.btnConcepto.disabled=true;
		document.form1.btnCtas.disabled=true;
		window.frames['itemFrame'].ctaDet.addCol.disabled=false;
		
		document.form1.cuentas1.value="";
		document.form1.cuentas2.value="";
		document.form1.cuentas3.value="";
		document.form1.cuentas4.value="";
		document.form1.cuentas5.value="";
		document.form1.cuentas6.value="";
		document.form1.cuentaName.value="";
	//eval('document.form0.observacion'+k).readOnly=true;
	//eval('document.form0.observacion'+k).className='FormDataObjectDisabled';
	//eval('document.form0.observacion'+k).value='';
	}
	
	
	
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - CUENTAS CONTABLES POR PLANILLA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0" id="_tblMain">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%> 
			<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("ctaLastLine",""+ctaLastLine)%>
			<%=fb.hidden("keySize",""+htcta.size())%>
			<%=fb.hidden("baction","")%>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer" colspan="2">
					<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
						  <td width="95%">&nbsp;Generales de la Planilla</td>
						  <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
				   </table>
				 </td>
			  </tr>
			  <tr id="panel0">
			  	<td colspan="2">
					<table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">	
							<td width="15%">C&oacute;d. Planilla</td>
							<td width="85%"><%=fb.select(ConMgr.getConnection(),"select cod_planilla as codpla, nombre, cod_planilla from tbl_pla_planilla where compania="+(String) session.getAttribute("_companyId")+"  and (is_visible ='S' or fg='EXT') order by 1","planillaId",ctasp.getPlanillaId(),true,false,viewMode,0,"Text10",null,"onChange=\"javascript:chkPlanilla()\"",null,"S")%></td>							
						
						</tr>						
					</table>
				</td>
			 </tr>
			 <tr>
				<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer" colspan="2">
					<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
						  <td width="95%">&nbsp;Generales de Configuracion</td>
						  <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
				   </table>
				 </td>
			  </tr>			  
			  <tr id="panel1">
			  	<td colspan="2">
					<table width="100%" cellpadding="1" cellspacing="1">
              			<tr class="TextRow01">
							<td>Tipo Asiento</td>
							<td><%=fb.select("tipo","A=DETALLADO,G=GENERAL",ctasp.getTipo(),false,(viewMode||!mode.equals("add")),0,"","","onChange=\"javascript:setCampos()\"")%>
							 
							</td>
								<td colspan="2">&nbsp;<%=fb.hidden("lado",ctasp.getLado())%></td>
						</tr>
						<tr class="TextRow01">
							<td width="15%">Unidad Administrativa</td>
							<td width="32%"%><%=fb.intBox("unidadAdminId",ctasp.getUnidadAdminId(),false,false,true,3,2)%></td>
							<td width="18%">Descripcion de Unidad</td>
							<td width="35%"><%=fb.textBox("unidadAdminName",ctasp.getUnidadAdminName(),false,false,true,42,2000)%>
							<%=fb.button("btnUnidad","...",true,(viewMode||!mode.equals("add")),null,null,"onClick=\"javascript:unidadAdm()\"","Agregar Unidad")%></td>
						</tr>
						<tr class="TextRow01">	
							<td>Cod. Concepto</td>
							<td><%=fb.intBox("conceptoId",ctasp.getConceptoId(),false,false,true,3,2,"",null,"onDblClick=\"javascript:clearConcepto()\"","Doble click para Limpiar Campos",false)%></td>
							<td>Descripci&oacute;n de Concepto</td>
							<td><%=fb.textBox("conceptoName",ctasp.getConceptoName(),false,false,true,42,2000)%>
							<%=fb.button("btnConcepto","...",true,viewMode,null,null,"onClick=\"javascript:conceptosPlan()\"","Agregar Conceptos")%>
							</td>
						</tr>							
						<tr class="TextRow01">	
							<td>Num. de la Cuenta</td>
							<td><%=fb.textBox("cuentas1",ctasp.getCta1(),true,false,true,2,3)%>
								<%=fb.textBox("cuentas2",ctasp.getCta2(),true,false,true,2,2)%>
								<%=fb.textBox("cuentas3",ctasp.getCta3(),true,false,true,2,3)%>
								<%=fb.textBox("cuentas4",ctasp.getCta4(),true,false,true,2,3)%>
								<%=fb.textBox("cuentas5",ctasp.getCta5(),true,false,true,2,3)%>
								<%=fb.textBox("cuentas6",ctasp.getCta6(),true,false,true,2,3)%>								
							<td>Nombre de la Cta</td>
							<td><%=fb.textBox("cuentaName",ctasp.getCuentaName(),false,false,true,42,2000)%>
								<%=fb.button("btnCtas","...",true,viewMode,null,null,"onClick=\"javascript:cuentasss()\"","Agregar Cuentas")%>
							</td>
						</tr>
						
						
					</table>
				</td>
			 </tr>
			 <tr class="TextRow02">
			  	<td colspan="2">&nbsp;</td>
			  </tr>
			 <tr>
				<td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer" colspan="2">
					<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
						  <td width="95%">&nbsp;Detalle de las Cuentas x Unidad Administrativa</td>
						  <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
						</tr>
				   </table>
				 </td>
			  </tr>
			  <tr id="panel2">
			  	<td colspan="2">
				<div id="panel1" style="inline:display;">
					<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="0" scrolling="yes" src="../rhplanilla/cta_x_planilla.jsp?mode=<%=mode%>&cta1=<%=cta1%>&cta2=<%=cta2%>&cta3=<%=cta3%>&ctaLastLine=<%=ctaLastLine%>"></iframe>

				</div>
				</td>
			  </tr>						
			<tr class="TextRow01">
				<td align="right">
				<%=fb.button("save","Guardar",true,viewMode,null, null, "onClick=\"window.frames['itemFrame'].doSubmit()\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
			</tr>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
				 <%=fb.formEnd(true)%>

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
 String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/ctacontable_x_planilla_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/ctacontable_x_planilla_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/ctacontable_x_planilla_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(errMsg);
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>