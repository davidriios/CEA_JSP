<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="OP" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iNotasCtas" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vNotasCtas" scope="session" class="java.util.Vector" />
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
OrdPagoMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
OrdenPago OrdPago = new OrdenPago();
String cDateTime  = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
int lineNo = 0;
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")||mode.equalsIgnoreCase("anular")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	System.out.println("................fp="+fp);
	System.out.println("................iNotasCtas="+iNotasCtas.size());
	
	if (mode.equalsIgnoreCase("add") && change == null && fp!=null && !fp.equals("INV")){ iNotasCtas.clear(); vNotasCtas.clear();}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{<%if(type!=null && type.equals("1")){%>abrir_ventana1('../common/check_cuentas.jsp?fp=ajuste_cxp&mode=<%=mode%>&id=<%=id%>');<%}%>
	verValues();newHeight();}
function doSubmit(){
	document.fact_prov.baction.value=parent.document.form1.baction.value;
	document.fact_prov.anio.value = parent.document.form1.anio.value;
	document.fact_prov.cod_tipo_ajuste.value = parent.document.form1.cod_tipo_ajuste.value;
	document.fact_prov.monto.value = parent.document.form1.monto.value;
	document.fact_prov.fecha.value = parent.document.form1.fecha.value;
	document.fact_prov.destino_ajuste.value = parent.document.form1.destino_ajuste.value;
	document.fact_prov.estado.value = parent.document.form1.estado.value;
	document.fact_prov.observacion.value = parent.document.form1.observacion.value;

	if(parent.document.form1.destino_ajuste.value=='P'||parent.document.form1.destino_ajuste.value=='G')document.fact_prov.cod_proveedor.value = parent.document.form1.ref_id.value;
	document.fact_prov.ref_id.value = parent.document.form1.ref_id.value;
	document.fact_prov.numero_factura.value = parent.document.form1.numero_factura.value;
	document.fact_prov.numero_documento.value = parent.document.form1.numero_documento.value;
	document.fact_prov.pagar_sino.value = parent.document.form1.pagar_sino.value;
	document.fact_prov.desc_proveedor.value = parent.document.form1.nombre.value;

	if (!fact_provValidation()){
		parent.form1BlockButtons(false);
		fact_provBlockButtons(false);
		return false;
	} else document.fact_prov.submit();
	
}
function chkCeroValues(){
	var size = document.fact_prov.keySize.value;
	var x = 0;
	var monto = 0.00;
	var parentMonto = parseFloat(parent.document.form1.monto.value);
	if(document.fact_prov.baction.value=="Guardar"){
		for(i=0;i<size;i++){
		  if(eval('document.fact_prov.action'+i).value !='D'){
		   
			if(eval('document.fact_prov.monto'+i).value=='' || eval('document.fact_prov.monto'+i).value<=0){
				alert('El monto no puede ser menor o igual a 0!');
				eval('document.fact_prov.monto'+i).focus();
				x++;
				break;
			} else{
			 monto += parseFloat(eval('document.fact_prov.monto'+i).value);
			}
		}
	  }
	}
	if(x==0){
		document.fact_prov.monto_total.value = monto.toFixed(2);
	if(document.fact_prov.baction.value=="Guardar" && monto.toFixed(2) != parentMonto){
			alert('Valor de factura Incorrecto!   '+monto +'-----'+parentMonto);
		return false;
		} else return true;
	} else return false;
}
function verValues()
{
var size = document.fact_prov.keySize.value;
var monto = 0.00;
var valor = 0.00;
for(i=0;i<size;i++)
 {

	if(eval('document.fact_prov.monto'+i).value!='')
	{
	if(eval('document.fact_prov.monto'+i).value>0&&eval('document.fact_prov.action'+i).value !='D' )
		{ 
		monto += parseFloat(eval('document.fact_prov.monto'+i).value);
		valor = parseFloat(eval('document.fact_prov.monto'+i).value);
		}
	}
	   // valor = parseFloat(eval('document.fact_prov.monto'+i).value);
		eval('document.fact_prov.monto'+i).value = valor.toFixed(2);
		valor = 0.00;
 }
	document.fact_prov.monto_total.value = monto.toFixed(2);
	if(parent.document.form1.monto)parent.document.form1.monto.value = monto.toFixed(2);
	//if(parent.document.form1.montoFact)parent.document.form1.montoFact.value = monto.toFixed(2);
}
function chkCeroRegisters(){var size = document.fact_prov.keySize.value;if(size>0) return true;else{if(document.fact_prov.baction.value!='Guardar') return true;else {alert('Seleccione al menos una Cuenta!');document.fact_prov.baction.value = '';return false;}}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("fact_prov",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%> 
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("baction","")%> 
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("clearHT","")%> 
<%=fb.hidden("action","")%> 
<%=fb.hidden("anio","")%> 
<%=fb.hidden("id",""+id)%> 
<%=fb.hidden("cod_tipo_ajuste","")%> 
<%=fb.hidden("monto","")%> 
<%=fb.hidden("fecha_sistema","")%> 
<%=fb.hidden("fecha","")%> 
<%=fb.hidden("fecha_documento","")%> 
<%=fb.hidden("numero_factura","")%> 
<%=fb.hidden("destino_ajuste","")%> 
<%=fb.hidden("estado","")%> 
<%=fb.hidden("observacion","")%> 
<%=fb.hidden("cod_proveedor","")%> 
<%=fb.hidden("desc_proveedor","")%> 
<%=fb.hidden("pagar_sino","")%> 
<%=fb.hidden("numero_documento","")%> 
<%=fb.hidden("ref_id","")%> 
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%fb.appendJsValidation("if(!chkCeroValues())error++;");%>
<%fb.appendJsValidation("if(!chkCeroRegisters())error++;");%>


<table width="100%" align="center">
  <tr>
    <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextPanel">
          <td colspan="5"><cellbytelabel>Detalle</cellbytelabel></td>
        </tr>
        <tr class="TextHeader">
		  <td width="40%" align="center"><cellbytelabel>N&uacute;mero de Cuenta</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
          <td width="45%" align="center"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
          <td width="5%" align="center">&nbsp;<%=fb.submit("addCuentas","+",false,viewMode,"","","onClick=\"javascript:setBAction(this.form.name,this.value);\"")%></td>
        </tr>
        <%
				key = "";
				if (iNotasCtas.size() != 0) al = CmnMgr.reverseRecords(iNotasCtas);
				for (int i=0; i<iNotasCtas.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) iNotasCtas.get(key);
					String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
		<%=fb.hidden("cta1_"+i,cdo.getColValue("cg_1_cta1"))%>
        <%=fb.hidden("cta2_"+i,cdo.getColValue("cg_1_cta2"))%>
        <%=fb.hidden("cta3_"+i,cdo.getColValue("cg_1_cta3"))%>
        <%=fb.hidden("cta4_"+i,cdo.getColValue("cg_1_cta4"))%>
        <%=fb.hidden("cta5_"+i,cdo.getColValue("cg_1_cta5"))%>
        <%=fb.hidden("cta6_"+i,cdo.getColValue("cg_1_cta6"))%>
		<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
        <%=fb.hidden("descripcion_cuenta"+i,cdo.getColValue("descripcion_cuenta"))%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("action"+i,cdo.getAction())%>
		<%=fb.hidden("key"+i,cdo.getKey())%>
		
		<%if(cdo.getAction().equalsIgnoreCase("D")){%>
		<%=fb.hidden("monto"+i,cdo.getColValue("monto"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%}else{%>
        <tr class="<%=color%>" >
		  <td><%=cdo.getColValue("cg_1_cta1")+"."+cdo.getColValue("cg_1_cta2")+"."+cdo.getColValue("cg_1_cta3")+"."+cdo.getColValue("cg_1_cta4")+"."+cdo.getColValue("cg_1_cta5")+"."+cdo.getColValue("cg_1_cta6")+" - "+cdo.getColValue("descripcion_cuenta")%></td>
		  <td align="center"><%=fb.decBox("monto"+i,cdo.getColValue("monto"),true,false,viewMode,10, 8.2,"text10",null,"onFocus=\"this.select();\"onChange = \"javascript:verValues();\"","Monto",false,"")%></td>
          <td align="center"><%=fb.textBox("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,60, "text10",null,"onFocus=\"this.select();\"")%></td>
          <td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
        </tr>
        <%}
				}
				%>
        <tr class="TextRow01" >
          <td align="right">&nbsp;<cellbytelabel>Total </cellbytelabel></td>
          <td align="center"><%=fb.decBox("monto_total","0",true,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Cantidad",false,"")%></td>
          <td colspan="2" align="center">&nbsp;</td>
        </tr>
        <%=fb.hidden("keySize",""+iNotasCtas.size())%> 
      </table></td>
  </tr>
</table>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
</body>
</html>
<%
}//GET 
else
{

	String saveOption = "C";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	String uAdmDel = "";
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	String itemRemoved="";

	OP.addColValue("anio",request.getParameter("anio"));
	OP.addColValue("id",request.getParameter("id"));
	OP.addColValue("cod_tipo_ajuste",request.getParameter("cod_tipo_ajuste"));
    OP.addColValue("monto",request.getParameter("monto")); 
    OP.addColValue("fecha",request.getParameter("fecha"));
	OP.addColValue("fecha_documento",request.getParameter("fecha_documento"));

	OP.addColValue("destino_ajuste",request.getParameter("destino_ajuste"));
	OP.addColValue("ref_id",request.getParameter("ref_id"));
    OP.addColValue("estado",request.getParameter("estado")); 
	OP.addColValue("usuario",request.getParameter("usuario"));
    OP.addColValue("cod_cia",(String) session.getAttribute("_companyId"));
	OP.addColValue("observacion",request.getParameter("observacion"));
	
	OP.addColValue("cod_proveedor",request.getParameter("cod_proveedor"));
	OP.addColValue("numero_factura",request.getParameter("numero_factura"));
	OP.addColValue("numero_documento",request.getParameter("numero_documento"));
	OP.addColValue("pagar_sino",request.getParameter("pagar_sino"));		
	OP.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	OP.addColValue("fecha_modificacion",cDateTime);

  if(request.getParameter("estado")!=null && request.getParameter("estado").equals("A")){ OP.addColValue("fecha_anulacion",cDateTime.substring(0,10));
  OP.addColValue("usuario_anulacion", (String) session.getAttribute("_userName"));
  }
  OP.addColValue("compania",(String) session.getAttribute("_companyId"));
  OP.addColValue("desc_proveedor", request.getParameter("desc_proveedor"));
  OP.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
  OP.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));

	iNotasCtas.clear();
	vNotasCtas.clear();
	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		CommonDataObject cdo = new CommonDataObject();
		//cdo.addColValue("renglon",request.getParameter("renglon"+i));
		cdo.addColValue("observacion",request.getParameter("observacion"+i));
		cdo.addColValue("cg_1_cta1",request.getParameter("cta1_"+i));
		cdo.addColValue("cg_1_cta2",request.getParameter("cta2_"+i));
		cdo.addColValue("cg_1_cta3",request.getParameter("cta3_"+i));
		cdo.addColValue("cg_1_cta4",request.getParameter("cta4_"+i));
		cdo.addColValue("cg_1_cta5",request.getParameter("cta5_"+i));
		cdo.addColValue("cg_1_cta6",request.getParameter("cta6_"+i));
		cdo.addColValue("descripcion_cuenta",request.getParameter("descripcion_cuenta"+i));
		cdo.addColValue("secuencia",request.getParameter("secuencia"+i));
		cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
		if(request.getParameter("monto"+i)!= null && !request.getParameter("monto"+i).equals("")) cdo.addColValue("monto", request.getParameter("monto"+i));
		
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
				iNotasCtas.put(cdo.getKey(),cdo);
				String ctas = cdo.getColValue("cg_1_cta1")+"_"+cdo.getColValue("cg_1_cta2")+"_"+cdo.getColValue("cg_1_cta3")+"_"+cdo.getColValue("cg_1_cta4")+"_"+cdo.getColValue("cg_1_cta5")+"_"+cdo.getColValue("cg_1_cta6");
				vNotasCtas.add(ctas);
				al.add(cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}
     
	if(!itemRemoved.equals("")){
		response.sendRedirect("../cxp/nota_ajuste_det.jsp?mode="+mode+"&id="+id+"&change=1&type=2&fg="+fg+"&fp="+fp);
		return;
	}
	if(request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("+")){
		response.sendRedirect("../cxp/nota_ajuste_det.jsp?mode="+mode+"&id="+id+"&change=1&type=1&fg="+fg+"&fp="+fp);
		return;
	}
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if (mode.equalsIgnoreCase("add")&& request.getParameter("baction")!=null && request.getParameter("baction").equals("Guardar")){
		OrdPago.setCdo(OP);
		OrdPago.setAlDet(al);
		OrdPagoMgr.addAjuste(OrdPago);
		id = OrdPagoMgr.getPkColValue("id");
	} else {
		OrdPago.setCdo(OP);
		OrdPago.setAlDet(al);
		OrdPagoMgr.updateAjuste(OrdPago);  
	}
	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (OrdPagoMgr.getErrCode().equals("1")){%>
			parent.document.form1.errCode.value = <%=OrdPagoMgr.getErrCode()%>;
			parent.document.form1.errMsg.value = '<%=OrdPagoMgr.getErrMsg()%>';
			parent.document.form1.id.value = '<%=id%>';
			parent.document.form1.submit();
	<%} else throw new Exception(OrdPagoMgr.getErrMsg());%>
		
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

