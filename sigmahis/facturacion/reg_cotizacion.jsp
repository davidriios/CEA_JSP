<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCargos" scope="session" class="java.util.Hashtable" /> 
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
String compania = (String) session.getAttribute("_companyId");
String key = "";
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cUserName = UserDet.getUserName(); 
boolean viewMode  = false;
ArrayList al = new ArrayList(); 

if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (fp == null) fp = "";
if (fg == null) fg = "COT";
if (id==null) id = "";
if (fp.equalsIgnoreCase("PAQ")) fg = fp;
if (mode.equalsIgnoreCase("view")) viewMode = true;
CommonDataObject cdoEnc = new CommonDataObject();
 
if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cdo = new CommonDataObject();

	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdoEnc.addColValue("id","0");
		cdoEnc.addColValue("fecha",""+cDate.substring(0,10));
		cdoEnc.addColValue("fecha_nac","");
		cdoEnc.addColValue("aplicaItbms","N");
		iCargos.clear();
	}
	else
	{
		if (id.trim().equals("")) throw new Exception("La Cotizacion no es válido. Por favor intente nuevamente!");

		sql = "select id, decode(esPac,'S',(select nombre_paciente from vw_adm_paciente where pac_id = c.pac_id),nombre) as nombre, estado, observacion, usuario_creacion, to_char(fecha_creacion ,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, usuario_modificacion usuarioModificacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion,identificacion, to_char(fecha_nac,'dd/mm/yyyy') as fecha_nac , to_char(fecha,'dd/mm/yyyy')  as fecha,medico,procedimiento,other1,other2,other3,esPac,(select primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))||', '||primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)  from tbl_adm_medico where codigo=c.medico ) as nombreMedico,cod_proc,pac_id,nvl(get_sec_comp_param(c.compania,'FACT_APLICA_ITBMS_ANTES_DESC'),'N') aplicaItbms,(select min(renglon) from tbl_fac_cotizacion_det where id=c.id) as renglon ,nvl(total_costo,0) as total_costo ,nvl(total,0) as total from tbl_fac_cotizacion c where id="+id;

		cdoEnc = SQLMgr.getData(sql);

		if (change == null)
		{		  
		   //DETALLE
		   sql = "select pd.id,pd.renglon,pd.descripcion,pd.cantidad,pd.descuento,pd.tipo_des,pd.other1,pd.other2,usuario_creacion, to_char(fecha_creacion ,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, usuario_modificacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion,monto,nvl(total,0) as total,nvl(totalDesc,0) as totalDesc ,nvl(impuesto,0) as impuesto, nvl(totalImp,0) as totalImp from tbl_fac_cotizacion_det pd where id = "+id;
 		   al = SQLMgr.getDataList(sql);
		   iCargos.clear();  
 		    for (int i=0; i<al.size(); i++)
			{
				  cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try {
					iCargos.put(cdo.getKey(),cdo); 
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
 		}// change == null
  	}

	if (cdoEnc == null) cdoEnc = new CommonDataObject();
 

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){getTotMonto();} 
document.title="Cotizacion - "+document.title; 
function _doSubmit(fName){
  if (canSubmit()){
    document.forms[fName].submit();
  }else{CBMSG.warning("Por favor ingrese nombre del Cliente!");}
}
function setBAction(fName,actionValue){document.forms[fName].baction.value = actionValue;}
function canSubmit(){return (document.form0.nombre.value!="");}
function printCotizacion(){abrir_ventana1("../facturacion/print_cotizacion.jsp?id=<%=id%>");}
function showMedicoList(){abrir_ventana1('../common/search_medico.jsp?fp=cotizacion');}
function clearMedico(){document.form0.medico.value='';document.form0.nombre_medico.value='';}
function showPacienteList(){abrir_ventana1('../common/search_paciente.jsp?fp=cotizacion');}
function showProcList(){abrir_ventana1('../common/sel_procedimiento.jsp?fp=cotizacion');}
function getTotMonto(){var desc=0.00,total=0.00,totalDesc=0.00,montoDesc=0.00,impuesto=0.00,totalImp=0.00;
  var s = parseInt("<%=iCargos.size()%>",10);
  var aplicaItbms = '<%=cdoEnc.getColValue("aplicaItbms")%>';
  var m = 0;
  for (i=0; i<s; i++)
  {
    monto = $("#monto"+i).val();
	desc = $("#descuento"+i).val();
	impuesto = $("#impuesto"+i).val();
	cantidad = $("#cantidad"+i).val();
	montoDesc=0.00 ; 
	totalNeto =0.00 ; 
	montoImpuesto=0.00 ; 
   if((monto!='' && monto!=' ') &&!isNaN(monto))
   { 
      m += cantidad * parseFloat(monto);
      if((desc!='' && desc!=' ') &&!isNaN(desc))
	  {
 	    montoDesc = cantidad *((parseFloat(monto)*parseFloat(desc))/100).toFixed(2);
 		totalDesc += parseFloat(montoDesc); 
 	  }
	  totalNeto = (monto*cantidad) - montoDesc;
	  
	  if((impuesto!='' && impuesto!=' ') &&!isNaN(impuesto))
	  {
 	    if(aplicaItbms=='S')montoImpuesto = (((parseFloat(totalNeto)+parseFloat(montoDesc))*parseFloat(impuesto))/100).toFixed(4);
		else montoImpuesto = ((parseFloat(totalNeto)*parseFloat(impuesto))/100).toFixed(4);
 		totalImp += parseFloat(montoImpuesto); 
 	  }
	  
 		 totalNeto += parseFloat(montoImpuesto);
		
		eval('document.form1.totalDesc'+i).value = montoDesc; 
		eval('document.form1.totalImp'+i).value = montoImpuesto; 
		eval('document.form1.total'+i).value = totalNeto.toFixed(2); 
	    total += totalNeto;
   }
   else
   {
   		eval('document.form1.totalDesc'+i).value =0.00;
		eval('document.form1.total'+i).value =0.00;
   }
  }//for 
 	
	var tmp=Math.round(m*100);
	m=tmp/100;
	document.form1.totalBruto.value=m.toFixed(2);
	document.form1.totalDesc.value=totalDesc.toFixed(2);
	document.form1.totalImp.value=totalImp.toFixed(4);
	document.form1.total.value=total.toFixed(2);
   return m;
}

function showDet(k){abrir_ventana('../facturacion/reg_cotizacion_det.jsp?id=<%=cdoEnc.getColValue("id")%>&mode=<%=mode%>&renglon='+k+'&fg=<%=fg%>&fp=<%=fp%>');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Paquete de Cargos"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<%if(!mode.equals("add")){%>
		<tr class="TextRow01"><td align="right"> <input type="button" value="Imprimir" class="CellbyteBtn" onClick="javascript:printCotizacion()" /></td></tr>
	<%}%>	
	<tr>
		<td class="TableBorder">
			<!-- MAIN DIV STARTS HERE -->
			<div id = "dhtmlgoodies_tabView1">
		
			<!-- TAB0 DIV STARTS HERE-->
			<div class = "dhtmlgoodies_aTab">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		    <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("id",cdoEnc.getColValue("id"))%>
			<%=fb.hidden("tab","0")%>
			<%=fb.hidden("cargosSize",""+iCargos.size())%> 
			<%=fb.hidden("fecha_creacion",cdoEnc.getColValue("fecha_creacion"))%>
			<%=fb.hidden("usuario_creacion",cdoEnc.getColValue("usuario_creacion"))%>
			<%=fb.hidden("esPac",cdoEnc.getColValue("esPac"))%>
			<%=fb.hidden("pac_id",cdoEnc.getColValue("pac_id"))%>
				<tr class="TextHeader">
					<td colspan="3" align="left">&nbsp;<cellbytelabel><%=(fg.trim().equals("COT"))?"Cotizacion":"Paquete"%></cellbytelabel></td>
				</tr>
				<tr class="TextRow01" >
					<td width="20%">&nbsp;<cellbytelabel>No. </cellbytelabel></td>
					<td width="60%">&nbsp;<%=cdoEnc.getColValue("id")%></td>
					<td width="20%">&nbsp;</td>
				</tr>
				
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="3"><%=(fg.trim().equals("COT"))?"Presentado a":"Descripcion"%>:</cellbytelabel></td>
					<td>&nbsp;<%=fb.textBox("nombre",cdoEnc.getColValue("nombre"),true,false,false,40,100)%>
					<%=(fg.trim().equals("COT"))?fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\""):""%>
					</td> 
					<td>&nbsp;<cellbytelabel id="3">Fecha</cellbytelabel> &nbsp;  
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=cdoEnc.getColValue("fecha")%>" />
								<jsp:param name="fieldClass" value="Text10" />
								<jsp:param name="buttonClass" value="Text10" />
								</jsp:include>
					</td>
				</tr>
				<%if(fg.trim().equals("COT")){%>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="3">Identificacion:</cellbytelabel></td>
					<td>&nbsp;<%=fb.textBox("identificacion",cdoEnc.getColValue("identificacion"),true,false,false,20,30)%></td> 
					<td>&nbsp;<cellbytelabel id="3">Fecha Nac.</cellbytelabel> &nbsp;  
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha_nac" />
								<jsp:param name="valueOfTBox1" value="<%=cdoEnc.getColValue("fecha_nac")%>" />
								<jsp:param name="fieldClass" value="Text10" />
								<jsp:param name="buttonClass" value="Text10" />
								</jsp:include>
					</td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="3">Medico:</cellbytelabel></td>
					<td colspan="2">&nbsp;<%=fb.textBox("medico",cdoEnc.getColValue("medico"),false,false,true,20,"Text10","","onDblClick=\"javascript:clearMedico();\"")%>								
								<%=fb.textBox("nombre_medico",cdoEnc.getColValue("nombreMedico"),false,false,true,40,"Text10","","onDblClick=\"javascript:clearMedico();\"")%>
								<%=fb.button("btnMedico","...",true,false,"Text10",null,"onClick=\"javascript:showMedicoList()\"")%>
 							  </td> 
 				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="3">Procedimiento:</cellbytelabel></td>
					<td colspan="2">&nbsp;
					<%=fb.textBox("cod_proc",cdoEnc.getColValue("cod_proc"),false,false,true,20,20,"Text10","","")%> 
					<%=fb.textBox("procedimiento",cdoEnc.getColValue("procedimiento"),false,false,false,100,100,"Text10","","")%>	 
					<%=fb.button("btnProc","...",true,false,"Text10",null,"onClick=\"javascript:showProcList()\"")%>
 							  </td> 
 				</tr><%}%>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="3">Estado:</cellbytelabel></td>
					<td colspan="2">&nbsp;<%=fb.select("estado","A=Activo,I=Inactivo,C=Cargos Realizados",cdoEnc.getColValue("estado"))%>	 
 							  </td> 
 				</tr>
				
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="4">Observaciones</cellbytelabel></td>
					<td colspan="2">&nbsp;<%=fb.textarea("observacion",cdoEnc.getColValue("observacion"),false,false,false,100,2,1000,null,null,null)%>
					</td>
				</tr>
				<%if(fp.trim().equals("PAQ")){%>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="4">DETALLE</cellbytelabel></td>
					<td colspan="2">&nbsp;<%=fb.button("btnDet","...",true,(mode.trim().equals("add")),"Text10",null,"onClick=\"javascript:showDet("+cdoEnc.getColValue("renglon")+");\"")%></td>
				</tr>
				 <!-- <tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="4">TOTAL PAQUETE</cellbytelabel></td>
					<td colspan="2">&nbsp;<%=fb.decBox("total",cdoEnc.getColValue("total"),false,false,true,13,"12.6",null,null,"")%> </td>
				</tr> -->
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="4">TOTAL COSTO</cellbytelabel></td>
					<td colspan="2">&nbsp;<%=fb.decBox("totalCosto",cdoEnc.getColValue("total"),false,false,true,13,"12.6",null,null,"")%> </td>
				</tr>
				  
				<%}%>
				<tr class="TextRow02">
					<td align="right" colspan="3">
 						<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:&nbsp;&nbsp;
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
						<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value); _doSubmit('"+fb.getFormName()+"')\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
		   </div><!-- TAB0 DIV ENDS HERE -->
		   
		   <!-- TAB1 DIV STARTS HERE -->
		   <div class="dhtmlgoodies_aTab">

				  <table align="center" width="100%" cellpadding="0" cellspacing="1">
				    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
					<%=fb.formStart(true)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("baction","")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("codigo","")%>
					<%=fb.hidden("tab","1")%>
					<%=fb.hidden("id",""+id)%>
					<%=fb.hidden("cargosSize",""+iCargos.size())%> 
					 <tr class="TextHeader01">
					 	<td colspan="9">[<%=id%>]<%=cdoEnc.getColValue("nombre")%></td>
					 </tr>
					 <tr class="TextHeader02"> 
						<td width="52%">Descripci&oacute;n</td> 
						<td width="6%" align="center">Cantidad</td>
						<td width="6%" align="center">Monto</td>
						<td width="6%" align="center">% Desc.</td>
						<td width="6%" align="center">Total Desc.</td> 
						<td width="6%" align="center">% Impuesto</td> 
						<td width="6%" align="center">Total Imp.</td>  
						<td width="6%" align="center">Total.</td>
						<td width="6%" align="center"><%=fb.submit("addReg","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
						</td>
					 </tr>

					<%
						al = CmnMgr.reverseRecords(iCargos);
						for (int i=0; i<iCargos.size(); i++)
						{
							key = al.get(i).toString();
							CommonDataObject cdoDet = (CommonDataObject) iCargos.get(key);
					%>
		<tr class="TextRow01">
		  <td><%=fb.textBox("descripcion"+i,cdoDet.getColValue("descripcion"),true,false,false,100,100,"","","")%>
		   
		  <%=fb.button("btnDet"+i,"...",true,(cdoDet.getColValue("renglon") == null || cdoDet.getColValue("renglon").trim().equals("")|| cdoDet.getColValue("renglon").trim().equals("0")),"Text10", null,"onClick=\"javascript:showDet("+cdoDet.getColValue("renglon")+");\"" )%>
		  
		  </td> 
		  <td align="left"><%=fb.intPlusBox("cantidad"+i,cdoDet.getColValue("cantidad"),true,false,viewMode,10,3,"",null,"onChange=\"javascript:getTotMonto()\"")%></td>
		  <td align="left"><%=fb.decBox("monto"+i,cdoDet.getColValue("monto"),true,false,viewMode,10,12.2,"",null,"onChange=\"javascript:getTotMonto()\"")%></td>
		  <td align="right"><%=fb.intPlusZeroBox("descuento"+i,cdoDet.getColValue("descuento"),false,false,false,2,2,null,null,"onChange=\"javascript:getTotMonto()\"")%></td>	
		  <td align="left"><%=fb.decBox("totalDesc"+i,cdoDet.getColValue("totalDesc"),false,false,true,10,12.2,null,null,"")%></td>
		  				
		  <td align="right"><%=fb.intPlusZeroBox("impuesto"+i,cdoDet.getColValue("impuesto"),false,false,false,2,2,null,null,"onChange=\"javascript:getTotMonto()\"")%></td>
		  <td align="left"><%=fb.decBox("totalImp"+i,cdoDet.getColValue("totalImp"),false,false,true,10,12.4,null,null,"")%></td>
		  <td align="left"><%=fb.decBox("total"+i,cdoDet.getColValue("total"),false,false,true,10,12.2,null,null,"")%></td>
		  <td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
						 
		<%=fb.hidden("action"+i,cdoDet.getAction())%>
		<%=fb.hidden("key"+i,cdoDet.getKey())%> 
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("tipo_des"+i,cdoDet.getColValue("tipo_des"))%>
		<%=fb.hidden("renglon"+i,cdoDet.getColValue("renglon"))%>
		<%=fb.hidden("usuario_creacion"+i,cdoDet.getColValue("usuario_creacion"))%>
		<%=fb.hidden("fecha_creacion"+i,cdoDet.getColValue("fecha_creacion"))%>		 
		<%=fb.hidden("other1"+i,cdoDet.getColValue("other1"))%>					
		<%=fb.hidden("other2"+i,cdoDet.getColValue("other2"))%>	 
		
					
	 <%}%>
					 
					<tr class="TextRow02">
					  <td align="center">&nbsp;</td>
					  <td align="center">&nbsp;</td>
					 <td align="right"><%=fb.decBox("totalBruto","",false,false,true,10,12.2,"",null,"")%></td>
					 <td align="right">&nbsp;</td>
					 <td align="right"><%=fb.decBox("totalDesc","",false,false,true,10,12.2,"",null,"")%></td>
					 <td align="right">&nbsp;</td>
					 <td align="right"><%=fb.decBox("totalImp","",false,false,true,10,12.4,"",null,"")%></td>
					 <td align="right"><%=fb.decBox("total","",false,false,true,10,12.2,"",null,"")%></td>
					<td>&nbsp;</td>
				  </tr>

				 <tr class="TextRow02">
					<td align="right" colspan="9">
						<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:&nbsp;&nbsp;
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
					 <%=fb.formEnd(true)%>
			      </table>

		   </div><!-- TAB1 DIV ENDS HERE --> 
 		   </div><!-- MAIN DIV ENDS HERE -->
		</td>
	</tr>
</table>
<script type="text/javascript">
<%
String disabledTab = "";
String tabLabel = "";
if(fg.trim().equals("COT"))tabLabel="'Cotizacion'";
else tabLabel="'Paquete'";
if (!mode.equalsIgnoreCase("add")&&!fp.trim().equals("PAQ")) tabLabel += ",'Detalle'";
%>

initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,null,[<%=disabledTab%>]);
</script>

</body>
</html>
<%
}//GET
else
{
    String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");

	if (tab.equals("0")){
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_fac_cotizacion");
		cdo.addColValue("compania", compania);
		cdo.addColValue("nombre",request.getParameter("nombre"));
		cdo.addColValue("identificacion",request.getParameter("identificacion"));
		cdo.addColValue("fecha_nac",request.getParameter("fecha_nac"));
		cdo.addColValue("fecha",request.getParameter("fecha"));
		cdo.addColValue("medico",request.getParameter("medico"));
		cdo.addColValue("procedimiento",request.getParameter("procedimiento"));
		cdo.addColValue("cod_proc",request.getParameter("cod_proc"));
		cdo.addColValue("pac_id",request.getParameter("pac_id"));
		cdo.addColValue("esPac",request.getParameter("esPac"));
		
		//cdo.addColValue("other1",request.getParameter("other1"));
		//cdo.addColValue("other2",request.getParameter("other2"));
		//cdo.addColValue("other3",request.getParameter("other3"));
		
		cdo.addColValue("estado",request.getParameter("estado"));
		cdo.addColValue("observacion",request.getParameter("observacion"));
		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modificacion","sysdate");
		   
	  if (mode.equalsIgnoreCase("add"))
	  {
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion","sysdate");
		cdo.addColValue("reg_type",fp);
		cdo.setAutoIncCol("id");
		cdo.addPkColValue("id","");
		
		SQLMgr.insert(cdo);
		id = SQLMgr.getPkColValue("id");
	  }
	  else
	  {
		cdo.setWhereClause("id="+id);
		SQLMgr.update(cdo);
	  }
    }
  	else if (tab.equals("1")) 
	{
		int size = 0;
		String itemRemoved = "";
		al.clear();
		iCargos.clear();
		
		if (request.getParameter("cargosSize") != null) size = Integer.parseInt(request.getParameter("cargosSize"));
		
		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_fac_cotizacion_det");
			cdo.setWhereClause("id = "+id+" and renglon = "+request.getParameter("renglon"+i)); 
			
			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));
			cdo.addColValue("id",id);
			
			if (baction.equalsIgnoreCase("Guardar") && cdo.getAction().equalsIgnoreCase("I"))
			{ 
				cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_creacion","sysdate");				
				cdo.setAutoIncCol("renglon");
			}
			else
			{
			  cdo.addColValue("renglon",request.getParameter("renglon"+i));
			}
			
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion","sysdate");	   
			
			
			cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
			cdo.addColValue("monto",request.getParameter("monto"+i));
			cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
			cdo.addColValue("tipo_des",request.getParameter("tipo_des"+i));
			cdo.addColValue("descuento",request.getParameter("descuento"+i));
			cdo.addColValue("other1",request.getParameter("other1"+i));
			cdo.addColValue("other2",request.getParameter("other2"+i)); 
			cdo.addColValue("totalDesc",request.getParameter("totalDesc"+i)); 
			cdo.addColValue("total",request.getParameter("total"+i)); 
			cdo.addColValue("impuesto",request.getParameter("impuesto"+i)); 
			cdo.addColValue("totalImp",request.getParameter("totalImp"+i)); 
			 
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}
 			if (!cdo.getAction().equalsIgnoreCase("X")) {
				try {
					iCargos.put(cdo.getKey(),cdo);
					al.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
 		}
		
		if (!itemRemoved.equals(""))
		{
			  
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&id="+id+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (baction != null && baction.equals("+"))
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setKey(iCargos.size()+1);
			cdo.setAction("I");
			cdo.addColValue("cantidad","1");
			cdo.addColValue("renglon","0");
			cdo.addColValue("tipo_des","P");
			cdo.addColValue("descuento","0");
			cdo.addColValue("impuesto","0");
			
			try
				{
						iCargos.put(cdo.getKey(),cdo);
				}
				catch(Exception e)
				{
						System.err.println(e.getMessage());
				}
				
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&mode="+mode+"&id="+id+"&fg="+fg+"&fp="+fp);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			
			cdo.setTableName("tbl_fac_cotizacion_det");
			cdo.setWhereClause("id="+id);

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true,false);
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
	window.opener.location = '<%=request.getContextPath()%>/facturacion/list_cotizacion.jsp?fp=<%=fp%>';
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&fg=<%=fg%>';
}

function editMode()
{
	window.opener.location = '<%=request.getContextPath()%>/facturacion/list_cotizacion.jsp?fp=<%=fp%>';
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?id=<%=id%>&mode=edit&tab=<%=tab%>&fg=<%=fg%>&fp=<%=fp%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>