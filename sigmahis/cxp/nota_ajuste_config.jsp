<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.StringTokenizer"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="iNotasCtas" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vNotasCtas" scope="session" class="java.util.Vector" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String anio = request.getParameter("anio");
String cDateTime  = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String cod = request.getParameter("cod");
String numero = request.getParameter("numero");
String codigo = request.getParameter("codigo");
if (cod == null) cod = "";
if (fg == null) fg = "";
if (fp == null) fp = "";
if (mode == null) mode = "add";
boolean viewMode = false;
boolean flag = true;
if (mode.equalsIgnoreCase("view")||mode.equalsIgnoreCase("anular")) viewMode = true;
cod = cod.replace("~",",");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	iNotasCtas.clear();
	vNotasCtas.clear();
		StringTokenizer st = new StringTokenizer(cod,",");
		while (st.hasMoreTokens()){
			if(flag && (code==null || code.equals(""))){
				code = st.nextToken();
			} else break;
		}


	if (mode.equalsIgnoreCase("add"))
	{
		if(fp.equals("INV")){
		
			sql="select decode((select sign_tipo_ajuste from tbl_inv_tipo_ajustes ta where ta.codigo_ajuste = aj.codigo_ajuste), '+', '1', '2') cod_tipo_ajuste, a.codigo ref_id, a.nombre nombre_proveedor, a.cta1, a.cta2,a.cta3, a.cta4, a.cta5, a.cta6, aj.codigo_almacen, round((select sum(da.cantidad_ajuste * da.precio) monto from tbl_inv_detalle_ajustes da, tbl_con_ctas_x_flia cf where da.compania = cf.compania and aj.codigo_almacen = cf.wh and da.cod_familia = cf.cod_flia and da.anio_ajuste = "+anio+"  and da.numero_ajuste = "+numero+" and da.codigo_ajuste = "+codigo+" and da.compania = "+(String) session.getAttribute("_companyId")+"), 2) monto from tbl_inv_ajustes aj, vw_cxp_beneficiarios a where aj.anio_ajuste = "+anio+" and aj.numero_ajuste = "+numero+" and aj.codigo_ajuste = "+codigo+" and aj.compania = "+(String) session.getAttribute("_companyId")+" and aj.cod_proveedor = a.codigo(+) and a.tipo(+) = 'PR'";
			cdo = new CommonDataObject();
			cdo = SQLMgr.getData(sql);
			
			sql = "select cf.cta1 cg_1_cta1, cf.cta2 cg_1_cta2, cf.cta3 cg_1_cta3, cf.cta4 cg_1_cta4, cf.cta5 cg_1_cta5, cf.cta6 cg_1_cta6, cg.descripcion descripcion_cuenta, sum(da.cantidad_ajuste * da.precio) monto from tbl_inv_detalle_ajustes da, tbl_con_ctas_x_flia cf, tbl_con_catalogo_gral cg where da.compania = cf.compania and "+cdo.getColValue("codigo_almacen")+" = cf.wh and da.cod_familia = cf.cod_flia and cf.compania = cg.compania and cf.cta1 = cg.cta1 and cf.cta2 = cg.cta2 and cf.cta3 = cg.cta3 and cf.cta4 = cg.cta4 and cf.cta5 = cg.cta5 and cf.cta6 = cg.cta6 and da.anio_ajuste = "+anio+"  and da.numero_ajuste = "+numero+" and da.codigo_ajuste = "+codigo+" and da.compania = "+(String) session.getAttribute("_companyId")+" group by cf.cta1, cf.cta2, cf.cta3, cf.cta4, cf.cta5, cf.cta6, cg.descripcion";
			al = SQLMgr.getDataList(sql);
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);

				cdoDet.setKey(i);
				cdoDet.setAction("I");


				try {
					iNotasCtas.put(cdoDet.getKey(),cdoDet);
					String ctas = cdoDet.getColValue("cg_1_cta1")+"_"+cdoDet.getColValue("cg_1_cta2")+"_"+cdoDet.getColValue("cg_1_cta3")+"_"+cdoDet.getColValue("cg_1_cta4")+"_"+cdoDet.getColValue("cg_1_cta5")+"_"+cdoDet.getColValue("cg_1_cta6");
					vNotasCtas.add(ctas);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+cdoDet.getKey());
				}
			}
		}
		
		cdo.addColValue("secuencia","0");
		cdo.addColValue("id","0");
		cdo.addColValue("anio",cDateTime.substring(6,10));	
		cdo.addColValue("fecha",cDateTime.substring(0,10));	
		cdo.addColValue("fecha",cDateTime.substring(0,10));	
		if(cdo==null) cdo.addColValue("monto","0");	
		if(!fp.equals("INV"))cdo.addColValue("monto","0");	
		cdo.addColValue("comprobante","N");
		code = "0";
		
	}
	else
	{
		if (code == null) throw new Exception("La Clasificación no es válida. Por favor intente nuevamente!");

		sql = "select a.anio, a.id, a.ref_id,a.cod_tipo_ajuste, nvl(a.monto,0) monto, to_char(a.fecha,'dd/mm/yyyy') fecha, a.observacion,a.numero_factura, decode(a.estado,'P','PENDIENTE','R','RECIBIDO','A','ANULADO') estadoDes, a.estado,nvl(decode(a.destino_ajuste,'H',(select m.primer_nombre || decode(m.segundo_nombre, null, '', ' ' || m.segundo_nombre) || ' ' || m.primer_apellido || decode(m.segundo_apellido, null, '', ' ' || m.segundo_apellido) || decode(m.sexo, 'F', decode(m.apellido_de_casada, null, '', ' ' || m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = to_char(a.ref_id)),'E',(select nombre from tbl_adm_empresa where codigo =a.ref_id),(select c.nombre_proveedor from tbl_com_proveedor c where c.compania=a.compania and c.cod_provedor=to_number(a.ref_id))),'S/NOMBRE') as nombre_proveedor, b.descripcion, a.destino_ajuste, a.numero_documento, a.pagar_sino, a.usuario_creacion as usuario,nvl(a.comprobante,'N')comprobante from tbl_cxp_ajuste_saldo_enc a, tbl_cxp_tipo_ajuste b where a.cod_tipo_ajuste = b.cod_tipo_ajuste and a.compania = "+(String) session.getAttribute("_companyId")+" and a.id = "+code;
		cdo = SQLMgr.getData(sql);
		//if(cdo.getColValue("comprobante")!=null && !cdo.getColValue("comprobante").trim().equals("")&& cdo.getColValue("comprobante").trim().equals("S"))viewMode = true;
		sql = "select a.anio, a.secuencia, a.cod_tipo_ajuste, nvl(a.monto,0) monto, to_char(a.fecha,'dd/mm/yyyy') fecha, a.observacion, a.cod_proveedor, a.numero_factura, decode(a.estado,'P','PENDIENTE','R','RECIBIDO','A','ANULADO') estadoDes, a.estado, a.correccion,a.destino_ajuste, a.numero_documento, a.pagar_sino, a.usuario, d.descripcion descripcion_cuenta, d.cta1 as cg_1_cta1, d.cta2 as cg_1_cta2, d.cta3 as cg_1_cta3, d.cta4 as cg_1_cta4, d.cta5 as cg_1_cta5, d.cta6 as cg_1_cta6,nvl(a.comprobante,'N')comprobante from tbl_cxp_ajuste_saldo a, tbl_con_catalogo_gral d where a.cod_cia = d.compania and a.cta1 = d.cta1 and a.cta2 = d.cta2 and a.cta3 = d.cta3 and a.cta4 = d.cta4 and a.cta5 = d.cta5 and a.cta6 = d.cta6 and a.cod_cia = "+(String) session.getAttribute("_companyId")+" and a.id_ref= "+code;
			al = SQLMgr.getDataList(sql);
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				
				cdoDet.setKey(i);
				cdoDet.setAction("U");
				try {
					iNotasCtas.put(cdoDet.getKey(), cdoDet);
					String ctas = cdoDet.getColValue("cg_1_cta1")+"_"+cdoDet.getColValue("cg_1_cta2")+"_"+cdoDet.getColValue("cg_1_cta3")+"_"+cdoDet.getColValue("cg_1_cta4")+"_"+cdoDet.getColValue("cg_1_cta5")+"_"+cdoDet.getColValue("cg_1_cta6");
					vNotasCtas.add(ctas);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+cdoDet.getKey());
				}
			}
		
 	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript" src="<%=request.getContextPath()%>/js/iframes_jq.js"></script>
<script language="javascript">
document.title = 'Notas de Ajuste - '+document.title;
function cuenta(){abrir_ventana1('../common/search_catalogo_gral.jsp?fp=ajuste');}
function clearRef()
{document.form1.numero_factura.value='';document.form1.monto.value=''; document.form1.ref_id.value='';document.form1.nombre.value='';}
function proveedor(){ document.form1.numero_factura.value='';document.form1.monto.value='0.00';if(document.form1.montoFact)document.form1.montoFact.value='0.00';var refType=document.form1.destino_ajuste.value;  if(refType=='P'||refType=='G')abrir_ventana1('../common/search_proveedor.jsp?fp=ajuste');else if(refType=='H') abrir_ventana1('../common/search_medico.jsp?fp=ajuste_cxp');else if(refType=='E') abrir_ventana1('../common/search_empresa.jsp?fp=ajuste_cxp');}
function verFactura(){var anio = document.form1.anio.value;var destino = document.form1.destino_ajuste.value;var sec = document.form1.id.value;var tipo = document.form1.cod_tipo_ajuste.value;var mode = document.form1.mode.value;
//var existe = getDBData('<%=request.getContextPath()%>','count(*) existe','tbl_cxp_ajuste_saldo_enc','compania =<%=(String) session.getAttribute("_companyId")%> and anio='+anio+' and id ='+sec+' and destino_ajuste = \''+destino+'\' and cod_tipo_ajuste=\''+tipo+'\'',''); if(mode=="add" && existe >= 1) CBMSG.warning('La Nota de Ajuste ya existe .... Revisar ');
var factura = document.form1.numero_factura.value;
var ref_id = document.form1.ref_id.value;
var contador = 0;
var tipo_ref='';
if (factura!=''){
if(destino=='H'){tipo_ref='M';}else tipo_ref='E';
if(destino=='P'||destino=='G'){
 contador = getDBData('<%=request.getContextPath()%>','count(*) contador','tbl_inv_recepcion_material','compania =<%=(String) session.getAttribute("_companyId")%> and estado = \'R\' and numero_factura=\''+factura+'\' and to_char(cod_proveedor) =\''+ref_id+'\'','');}
 else{
  contador = getDBData('<%=request.getContextPath()%>','nvl(getsaldoFactHon(<%=(String) session.getAttribute("_companyId")%>,\''+ref_id+'\',\''+tipo_ref+'\',\''+factura+'\'),0)','dual','','');
 	if(contador != 0) contador=1;
  }

    if(contador == 0){CBMSG.warning('No hay Factura con esa Numeración Registrada para ajustar....');}
	
  }
}
function buscaDoc(){document.form1.numero_factura.value='';document.form1.monto.value='0.00';if(document.form1.montoFact)document.form1.montoFact.value='0.00';var codProveedor = document.form1.ref_id.value;if(codProveedor=='') CBMSG.warning('Seleccione a Favor De:!');else{var refType=document.form1.destino_ajuste.value;var tipoAjuste=document.form1.cod_tipo_ajuste.value;  if(refType=='P'||refType=='G')abrir_ventana1('../inventario/sel_recepcion.jsp?fp=ajuste&fg=CXP&codProveedor='+codProveedor+'&refType='+refType+'&tipoAjuste='+tipoAjuste);else if(refType=='H'||refType=='E')abrir_ventana1('../facturacion/facturas_ajuste_list.jsp?fp=ajuste_cxp&ref_type='+refType+"&cod_honorario="+codProveedor);}}
function doSubmit(fname,baction){if(form1Validation()){setBAction(fname,baction);window.frames['itemFrame'].doSubmit();}}
function printDoc()
{abrir_ventana1('../cxp/print_notas_ajuste.jsp?fp=ajuste&fg=CXP&id=<%=code%>&anio=<%=anio%>');}
function changeCod(codigo){var cod = document.form1.cod.value;	window.location = '../cxp/notas_ajustes_config.jsp?mode=view&fp=cons&fg=<%=fg%>&code='+codigo+'&cod='+cod;}
function clearFact()
{if(document.form1.montoFact)document.form1.montoFact.value='0.00';}
function checkEstado(){
var fecha='';
var estado = document.form1.estado.value;
if(estado=='A')fecha= '<%=cDateTime.substring(0,10)%>'; else fecha = document.form1.fecha.value;
var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){document.form1.fecha.value='';return false;}else return true;}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR PAGAR - TRANSACCIONES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">			

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("usuario",cdo.getColValue("usuario"))%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("clearHT","")%>
			<%=fb.hidden("baction","")%>
            <%=fb.hidden("fg",fg)%>
			<%=fb.hidden("cod",cod)%>
				<tr>
					<td colspan="6">&nbsp;</td>
				</tr>
				<tr class="TextHeader">
								<td colspan="6">&nbsp;<cellbytelabel>Registro de Notas de Ajuste a Proveedor</cellbytelabel> </td>
				</tr>
				<tr class="TextRow02">
					<td colspan="6">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="13%"><cellbytelabel>Ajuste No</cellbytelabel>. : </td>
					<td width="22%">
					<%if(fg.equalsIgnoreCase("CS")){%>
					<%=fb.select("id",cod,code,false,false,0,"",null,"onChange=\"javascript:changeCod(this.value);\"")%>
					<%} else {%>
					<%=fb.textBox("id",cdo.getColValue("id"),true,false,true,10)%>
					<%}%>
					
				  <cellbytelabel>A&ntilde;o</cellbytelabel> : <%=fb.textBox("anio",cdo.getColValue("anio"),true,false,false,6,6)%></td>			
					<td width="15%" align="center"><cellbytelabel>Fecha</cellbytelabel> : </td>
					<td width="14%">
					<%String checkEstado = "javascript:checkEstado();newHeight();";%>
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="fecha" />
					<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fecha")==null)?"":cdo.getColValue("fecha")%>" />		
					<jsp:param name="jsEvent" value="<%=checkEstado%>" />
					<jsp:param name="onChange" value="<%=checkEstado%>" />
					<jsp:param name="readonly" value="<%=(viewMode||cdo.getColValue("comprobante").trim().equals("S"))?"y":"N"%>" />
					</jsp:include></td>		
					<td width="11%" align="right"><cellbytelabel>Estado</cellbytelabel> : </td>
					<td width="25%">
					<%String descEstado ="P=PENDIENTE,R=APROBADO";if(mode.trim().equals("anular"))descEstado ="R=APROBADO,A=ANULADO";
					if(mode.trim().equals("view"))descEstado +=",A=ANULADO";
					%>
					<%=fb.select("estado",(mode.trim().equals("add"))?"P=PENDIENTE,R=APROBADO":descEstado,cdo.getColValue("estado"),false,(viewMode&&(!mode.trim().equals("anular")&&!cdo.getColValue("estado").trim().equals("A"))),0,"","","onChange=\"javascript:checkEstado()\"")%></td>	
				</tr>	
				
				<tr class="TextRow01">
					<td> <cellbytelabel>Tipo de Ajuste</cellbytelabel> : </td>
					<td colspan="3">
					<%if(cdo.getColValue("comprobante").trim().equals("S")){%>
					<%=fb.hidden("cod_tipo_ajuste",cdo.getColValue("cod_tipo_ajuste"))%>
					<%=fb.select(ConMgr.getConnection(), "select cod_tipo_ajuste, descripcion from tbl_cxp_tipo_ajuste ", "cod_tipo_ajusteView", cdo.getColValue("cod_tipo_ajuste"),false,true,0)%><%}else{%>
					<%=fb.select(ConMgr.getConnection(), "select cod_tipo_ajuste, descripcion from tbl_cxp_tipo_ajuste ", "cod_tipo_ajuste", cdo.getColValue("cod_tipo_ajuste"),false,viewMode,0,"Text10",null,"onChange=\"javascript:clearFact();\"")%>
					<%}%>
					</td>			
						
					<td align="right"><cellbytelabel>Ajustar a</cellbytelabel>: </td>
					<td><%=fb.select("destino_ajuste","P=PROVEEDOR - INVENTARIO,G=PROVEEDOR - GASTOS,H=MEDICOS,E=SOCIEDADES MEDICAS",cdo.getColValue("destino_ajuste"),false,viewMode,0,"Text10",null,"onChange=\"javascript:clearRef();\"","","")%>
					
					</td>	
				</tr>	
				
				<tr class="TextRow01">
					<td> <cellbytelabel>A Favor De:</cellbytelabel> : </td>
					<td colspan="5">
					<%=fb.textBox("ref_id",cdo.getColValue("ref_id"),true,false,true,8)%>&nbsp;
					<%=fb.textBox("nombre",cdo.getColValue("nombre_proveedor"),false,false,true,59)%>
				  <%=fb.button("btnproveedor","...",false,(viewMode || cdo.getColValue("comprobante").trim().equals("S")),null,null,"onClick=\"javascript:proveedor()\"")%></td>			
			 </tr>	
										
			<tr class="TextRow01">
					<td> <cellbytelabel>Factura No</cellbytelabel>. : </td>
					<td><%=fb.textBox("numero_factura",cdo.getColValue("numero_factura"),false,false,viewMode,25,22,null,null,"onChange=\"javascript:verFactura()\"")%>  <%=fb.button("buscar","...",false,viewMode,"","","onClick=\"javascript:buscaDoc()\"")%></td>
					<td> <cellbytelabel>Nota No</cellbytelabel>. : </td>
					<td> <%=fb.textBox("numero_documento",cdo.getColValue("numero_documento"),false,false,viewMode,25,22)%>
				  
					<td align="right">&nbsp;<!--<cellbytelabel>Pagado</cellbytelabel> : --></td>
					<td><%=fb.hidden("pagar_sino","N")%><%//=fb.select("pagar_sino","N= NO",cdo.getColValue("pagar_sino"),false,viewMode,0)%></td>		
						
			</tr>				
			
			<tr class="TextRow01">
					<td> <cellbytelabel>Monto Ajuste</cellbytelabel>. : </td>
			  <td><%=fb.decBox("monto",cdo.getColValue("monto"),true,false,(viewMode||cdo.getColValue("comprobante").trim().equals("S")),15,8.2)%></td>
					<%
					if (mode.equalsIgnoreCase("add")) {
					%>
					<td colspan="2">&nbsp;<cellbytelabel>Monto Factura</cellbytelabel> :   <%=fb.textBox("montoFact","",false,false,true,15,2)%></td>
					<%} else { %>
					<td colspan="2">&nbsp; </td>
				<% } %>
				 <!-- <td align="right"> <cellbytelabel>Ajuste para</cellbytelabel> : </td>
					<td><%//=fb.select("correccion","C=COMPROBANTE,O=OTROS",cdo.getColValue("correccion"),"S")%></td>	-->
					
					<td>&nbsp; </td>
					<td>&nbsp; </td>
			</tr>	
			<tr class="TextRow01">							
					<td align="right"><cellbytelabel>Observaci&oacute;n</cellbytelabel> : </td>
				  <td colspan="3"><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,viewMode,45,6)%>
				  <td colspan="2" valign="middle"><%=fb.button("reporte","IMPRIMIR",false,(mode.trim().equals("add"))?true:false,"","","onClick=\"javascript:printDoc()\"")%></td>	
				</tr>	
			<tr>
                <td colspan="6"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="99" scrolling="no" src="../cxp/nota_ajuste_det.jsp?mode=<%=(cdo.getColValue("comprobante").trim().equals("S"))?"view":mode%>&fg=<%=fg%>&id=<%=code%>&fp=<%=fp%>"></iframe></td>
            </tr>
       <tr class="TextRow02">
			   <td colspan="6" align="right">
				            <cellbytelabel>Opciones de Guardar</cellbytelabel>:
					<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro </cellbytelabel>
					<%=fb.radio("saveOption","O",false,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
					<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
		            <%=fb.button("save","Guardar",true,(viewMode&&!mode.trim().equals("anular")),"","","onClick=\"javascript:doSubmit(this.form.name,this.value);\"")%>
				    <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
			<%fb.appendJsValidation("if(!checkEstado()){error++;CBMSG.warning('Revise Fecha de la Transaccion!');}");%>			
		<%=fb.formEnd(true)%>
            </table>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</td>    
	</tr>
</table>		
</body>
</html>
<%
}//GET
else
{ 
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close

	code = request.getParameter("id");
	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function unload(){closeChild=false;}
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxp/nota_ajuste_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxp/nota_ajuste_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/cxp/nota_ajuste_list.jsp?';
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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fg=<%=fg%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&anio=<%=request.getParameter("anio")%>&code=<%=request.getParameter("id")%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
