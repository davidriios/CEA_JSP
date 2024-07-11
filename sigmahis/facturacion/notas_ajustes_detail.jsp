<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.NotasAjustes"%>
<%@ page import="issi.facturacion.NotasAjustesDet"%>
<%@ page import="issi.facturacion.NotasAjustesMgr"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iNotas" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="NAMgr" scope="page" class="issi.facturacion.NotasAjustesMgr"/>
<%
/**
=========================================================================
 NOTA: SE UTILIZARÀ EL CAMPOR FARHOSP PARA INDICAR QUE ES UN CARGO ADICIONAL POR LOS CASOS DE DEVOLUCION DE CHEQUES.
=========================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
NAMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String factura = request.getParameter("factura");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String tipoCliente = request.getParameter("tipoCliente");
String isAjusteAut = request.getParameter("isAjusteAut")==null?"":request.getParameter("isAjusteAut");
String key = "";
String sql = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
boolean viewMode = false;
int notasLastLineNo = 0;
if (mode != null && mode.equalsIgnoreCase("view")) viewMode = true;

if (factura == null || factura.equalsIgnoreCase("")) factura="";
if (request.getParameter("notasLastLineNo") != null && !request.getParameter("notasLastLineNo").equals("")) notasLastLineNo = Integer.parseInt(request.getParameter("notasLastLineNo"));
if (fp == null ) fp = "";
if (fg == null ) fg = "";
if (tipoCliente == null ) tipoCliente = "E";
if (request.getMethod().equalsIgnoreCase("GET"))
{ 
%>
<!doctype html>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Notas Ajustes - '+document.title;

function getTotMonto(){
  var s = parseInt("<%=iNotas.size()%>",10);
  var m = 0;
  for (i=0; i<s; i++){
    monto = $("#monto"+i).val();
   if((monto!='' && monto!=' ') &&!isNaN(monto)) m += parseFloat(monto);
  }
<% if (!fg.trim().equals("AR")) { %>
	var tmp=Math.round(m*100);
	m=tmp/100;
	parent.document.form0.total.value=m.toFixed(2);
<% } %>
  return m;
}

function doSubmit()
{   
	 document.form1.baction.value = parent.document.form0.baction.value;
   document.form1.codigo.value = parent.document.form0.codigo.value;
	 document.form1.compania.value = parent.document.form0.compania.value;
   document.form1.explicacion.value = parent.document.form0.explicacion.value;
	 document.form1.fecha.value = parent.document.form0.fecha.value;
   document.form1.usuario_creacion.value = parent.document.form0.usuario_creacion.value;
   document.form1.fecha_creacion.value = parent.document.form0.fecha_creacion.value;
   document.form1.tipo_doc.value = parent.document.form0.tipo_doc.value;
	 if(parent.document.form0.tipo_docto) document.form1.tipo_docto.value = parent.document.form0.tipo_docto.value;
   if(parent.document.form0.tipo_doc.value=='F') document.form1.factura.value = parent.document.form0.factura.value;
   document.form1.tipo_ajuste.value = parent.document.form0.tipo_ajuste.value;
   if(parent.document.form0.recibo)document.form1.recibo.value = parent.document.form0.recibo.value; 
   document.form1.factura_aplic.value = parent.document.form0.factura_aplic.value;
   document.form1.total.value = parent.document.form0.total.value;
   document.form1.estatus.value = parent.document.form0.estatus.value;
	 document.form1.referencia.value = parent.document.form0.referencia.value;
   document.form1.act_sn.value = parent.document.form0.act_sn.value;
	 document.form1.sigla.value = parent.document.form0.sigla.value;
   document.form1.tomo.value = parent.document.form0.tomo.value;
   document.form1.asiento.value = parent.document.form0.asiento.value;
   document.form1.provincia.value = parent.document.form0.provincia.value;
	if(parent.document.form0.ctrlajuste){if(parent.document.form0.ctrlajuste.checked)
	 document.form1.credito.value = "S";
	 else document.form1.credito.value = "N";}else document.form1.credito.value = "N";
   document.form1.pase.value = parent.document.form0.pase.value;
   document.form1.pase_k.value = parent.document.form0.pase_k.value;
   document.form1.ref_reversion.value = parent.document.form0.ref_reversion.value;
   document.form1.anio_parametro.value = parent.document.form0.anio_parametro.value;
   document.form1.mes_parametro.value = parent.document.form0.mes_parametro.value;
   
   document.form1.fecha_nacimiento.value = parent.document.form0.fecha_nacimiento.value;
   document.form1.pac_id.value = parent.document.form0.pac_id.value;
   document.form1.codigo_paciente.value = parent.document.form0.codigo_paciente.value;
   document.form1.ref_type.value = parent.document.form0.ref_type.value;
   document.form1.ref_id.value = parent.document.form0.ref_id.value;

   if (form1Validation())
   {
	if (CheckMonto())
	  document.form1.submit(); 
   }else doAction();
}
function setBAction(fName,actionValue)
{
	 if(parent.document.form0.tipo_doc.value=='F')document.form1.factura.value = parent.document.form0.factura.value;
	if(parent.document.form0.tipo_docto) document.form1.tipo_docto.value = parent.document.form0.tipo_docto.value;
	document.forms[fName].baction.value = actionValue;
}
function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}


function doAction()
{
	getTotMonto();
	if (parent.adjustIFrameSize){ parent.adjustIFrameSize(window);
	parent.form0BlockButtons(false)};
}
function showDetalle(k)
{
var tipo = eval('document.form1.tipo'+k).value;
var factura = eval('document.form1.factura'+k).value;

if(tipo=="C")//Centro de Servicio
abrir_ventana2('../common/search_centro_servicio.jsp?fp=notas_ajustes&index='+k+'&factura='+factura);
else if(tipo=="E")//Empresa
abrir_ventana2('../common/search_empresa.jsp?fp=notas_ajustes&index='+k);
else if(tipo=="H")//medico
abrir_ventana2('../common/search_medico.jsp?fp=notas_ajustes&index='+k);
}
function clearCodigo(k)
{
eval('document.form1.v_codigo'+k).value="";
eval('document.form1.name_code'+k).value="";
eval('document.form1.monto'+k).value="";
}
function Facturas(k)
{
	abrir_ventana2('../facturacion/facturas_ajuste_list.jsp?fp=notas_h&index='+k);
}
function BtnAct()
{
	parent.form0BlockButtons(false);
}
function CheckMonto()
{
var x = 0;
var conta = 0;
var tot_db = 0;
var tot_cr = 0;
var aconta = 0;
var msg = '';

if(parent.document.form0.tipo_doc.value == "R" && parent.document.form0.recibo.value=="")
{
	top.CBMSG.warning('INTRODUZCA NUMERO DE RECIBO');
	return false;
}
if(x>0){return false;}
else{ 

var size1 = parseInt(document.getElementById("keySize").value);

if(size1 ==0){top.CBMSG.warning('NO PUEDE REGISTRAR AJUSTE SIN DETALLE!!!');x++;return false;}
var totalCr =0.00,totalDb =0.00;
for (i=0;i<size1;i++)
{

if((parent.document.form0.tipo_doc.value == "F" && eval('document.form1.v_codigo'+i).value=="") && (eval('document.form1.tipo'+i).value != "P" && eval('document.form1.tipo'+i).value!="M"))
{
	top.CBMSG.warning('EL CAMPO CODIGO ESTA EN BLANCO...VERIFIQUE');
	x++;
}
if(x>0)	return false;

if(eval('document.form1.lado_mov'+i).value == "D")
	       tot_db +=  parseFloat(eval('document.form1.monto'+i).value);//+ tot_db ;
else if(eval('document.form1.lado_mov'+i).value == "C")
	       tot_cr += parseFloat(eval('document.form1.monto'+i).value);
}//CBMSG.warning('tot_db = '+tot_db+'  tot_cr = '+tot_cr);
	totalCr = tot_cr.toFixed(2);
	totalDb = tot_db.toFixed(2);

	if(totalDb > 0 && totalCr > 0)
	{
		if(totalDb == parseFloat(parent.document.form0.total.value) && totalCr == parseFloat(parent.document.form0.total.value))
		 conta=1;
		else conta = 2;
	}
	if(totalDb > 0 && totalCr == 0)
	{
		if(totalDb == parseFloat(parent.document.form0.total.value))
		 conta=1;
		else conta = 2;
	}
	if(totalDb == 0 && totalCr > 0)
	{
		if(totalCr == parseFloat(parent.document.form0.total.value))
		 conta=1;
		else conta = 2;
	}
	eval('document.form1.conta').value=conta;
	if(conta==2)
	{
	/*CBMSG.warning('conta ='+conta);
	//genera reamnente
	}
	else
	{*/
		top.CBMSG.warning('REVISE MONTOS DE LA NOTA DE AJUSTE');
		x++;
	}
	if(parent.document.form0.tipo_doc.value == "R")
	{
		var ctrlajuste = parent.document.form0.ctrlajuste.value;
		var totalRecibo = parseFloat(parent.document.form0.totalRecibo.value);
		if ( ctrlajuste != 'N')
		{
			if(totalCr  > totalRecibo ||  totalDb > totalRecibo )
			{
				top.CBMSG.warning('REVISE MONTOS DE LA NOTA DE AJUSTE EL RECIBO NO TIENE EL SALDO QUE DESEA AJUSTAR');
				x++;
			}
		}
	}
	if(x>0)	return false;
	else return true;	
	}

}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("notasLastLineNo",""+notasLastLineNo)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("codigo","")%>
			<%=fb.hidden("conta","")%>
			<%=fb.hidden("compania","")%>
			<%=fb.hidden("explicacion","")%>
			<%=fb.hidden("fecha","")%>
			<%=fb.hidden("usuario_creacion","")%>
			<%=fb.hidden("fecha_creacion","")%>
			<%=fb.hidden("tipo_doc","")%>
			<%=fb.hidden("tipo_docto","")%>
			<%=fb.hidden("factura",""+factura)%>
			<%=fb.hidden("tipo_ajuste","")%>
			<%=fb.hidden("recibo","")%>
			<%=fb.hidden("factura_aplic","")%>
			<%=fb.hidden("total","")%>
			<%=fb.hidden("estatus","")%>
			<%=fb.hidden("referencia","")%>
			<%=fb.hidden("act_sn","")%>
			<%=fb.hidden("credito","")%>			
			<%=fb.hidden("pase","")%>
			<%=fb.hidden("pase_k","")%>
			<%=fb.hidden("ref_reversion","")%>
			<%=fb.hidden("provincia","")%>
			<%=fb.hidden("sigla","")%>
			<%=fb.hidden("tomo","")%>
			<%=fb.hidden("asiento","")%>
			<%=fb.hidden("anio_parametro","")%>
			<%=fb.hidden("mes_parametro","")%>
			<%=fb.hidden("keySize",""+iNotas.size())%>
			<%=fb.hidden("fecha_nacimiento","")%>
			<%=fb.hidden("pac_id","")%>
			<%=fb.hidden("codigo_paciente","")%>	
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("ref_type","")%>
			<%=fb.hidden("ref_id","")%>	
			<%=fb.hidden("isAjusteAut",isAjusteAut)%>			
			<tr class="TextHeader" align="center"> 
				<td width="5%"><%//=sbSql.toString()%><cellbytelabel>No</cellbytelabel>.</td>
				<td width="13%"><cellbytelabel>Factura</cellbytelabel></td>
				<%if(fg.equals("AR")||mode.trim().equals("view")){%>
				<td width="10%">Lado Mov</td>
				<%}%>
				<td width="13%"><cellbytelabel>Tipo</cellbytelabel></td>
				<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width="25%">Descripci&oacute;n</td>
				<td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
				<td width="4%"><cellbytelabel>Pag</cellbytelabel></td>
				<td width="5%"><cellbytelabel>Cheque</cellbytelabel></td>
				<td width="5%"><cellbytelabel>C.Adicional</cellbytelabel></td>
				<td width="5%"><%=fb.submit("agregar","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
		</tr>
				<%	
				    String js = "";		  
				    al = CmnMgr.reverseRecords(iNotas);				
				    for (int i = 0; i < iNotas.size(); i++)
				    {
					  key = al.get(i).toString();	
					  NotasAjustesDet na = (NotasAjustesDet) iNotas.get(key);
						String color = "TextRow02";
	 					if (i % 2 == 0) color = "TextRow01";
			    %>
				<%=fb.hidden("nota_ajuste"+i,na.getNotaAjuste())%> 
				<%=fb.hidden("compania"+i,na.getCompania())%> 
				<%=fb.hidden("cod_banco"+i,na.getCodBanco())%> 
				<%=fb.hidden("cuenta_banco"+i,na.getCuentaBanco())%> 
				<%=fb.hidden("monto_saldo"+i,na.getMontoSaldo())%> 
				<%=fb.hidden("descripcion"+i,na.getDescripcion())%> 
   				<%=fb.hidden("usuario_creacion"+i,na.getUsuarioCreacion())%> 
				<%=fb.hidden("fecha_creacion"+i,na.getFechaCreacion())%> 
				<%=fb.hidden("paciente"+i,na.getPaciente())%> 
				<%=fb.hidden("amision"+i,na.getAmision())%> 
				<%=fb.hidden("fecha_nacimiento"+i,na.getFechaNacimiento())%>
				<%=fb.hidden("pac_id"+i,na.getPacId())%>
				<%=fb.hidden("cliente_emp"+i,na.getClienteEmp())%> 
	 			<%=fb.hidden("afecta"+i,na.getAfecta())%> 
				<%=fb.hidden("pase"+i,na.getPase())%>
				<%=fb.hidden("fact_clinica"+i,na.getFactClinica())%> 
				<%=fb.hidden("puntos_sino"+i,na.getPuntosSino())%>
				<%=fb.hidden("pase_k"+i,na.getPaseK())%> 
				<%=fb.hidden("key"+i,key)%> 
				<%=fb.hidden("remove"+i,"")%>
				<%=fb.hidden("pagado"+i,na.getPagado())%>
				
				<tr class="<%=color%>"> 
				<td><%=fb.intBox("secuencia"+i,na.getSecuencia(),false,false,true,5,10)%></td>
				<td><%=fb.textBox("factura"+i,(na.getFactura()!= null && !na.getFactura().trim().equals("")&& !na.getFactura().trim().equals("null"))?na.getFactura():factura,false,false,true,10,12)%><%=fb.button("addFact"+i,"...",true,((fg.equals("AF")||fg.equals("AR"))||viewMode),null,null,"onClick=\"javascript:Facturas("+i+")\"","Facturas")%></td>
				<%if(fg.equals("AR")||mode.trim().equals("view")){%>
				<td><%=fb.select("lado_mov"+i,"C = CREDITO,D=DEBITO",na.getLadoMov(),false,viewMode,0,"",null,"")%></td>
				<%} else {%>
				<%=fb.hidden("lado_mov"+i,na.getLadoMov())%>
				<%}%>
				<td>
				<%
				String _tipo = "C = CENTRO, E = EMPRESA,H=MEDICO";
				if(mode.trim().equals("view")) _tipo += ",P= CO-PAGO, M=PERDIEM";
				//if(isAjusteAut.equals("Y")) _tipo = "C=CENTRO";
				%>
				<%=fb.select("tipo"+i,_tipo,na.getTipo(),false,(viewMode||(isAjusteAut.equals("Y"))),0,"",null,"onChange=\"javascript:clearCodigo("+i+")\"")%>
				
				</td>
				<td><%=fb.textBox("v_codigo"+i,(na.getDescCentro()!=null && (na.getTipo()!=null && na.getTipo().trim().equals("H")))?na.getMedico():na.getDescCentro(),false,false,true,5,30)%></td>
				<td><%=fb.textBox("name_code"+i,na.getDescAjusteDet(),false,false,true,25,30)%>
				<%=fb.button("addDesc"+i,"...",true,(viewMode||isAjusteAut.equals("Y")),null,null,"onClick=\"javascript:showDetalle("+i+")\"","Detalle")%></td>
				<td><%=fb.decBox("monto"+i,na.getMonto(),true,false,viewMode,10,15.2,"Text10",null,"onChange=\"javascript:getTotMonto()\"")%></td>
				<td align="center"><%=fb.checkbox("pagado_view"+i,"S",(na.getPagado().trim().equals("S")),true,null,null,"")%></td>
				<td><%=fb.textBox("num_cheque"+i,na.getNumCheque(),false,false,true,5,11)%></td>
				<td align="center"><%=fb.select("farhosp"+i,"S = SI, N = NO",na.getFarhosp(),false,viewMode,0,"",null,"")%></td>
				<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
				<%}%>  				 				 	
        <%=fb.formEnd(true)%>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{
		int keySize=Integer.parseInt(request.getParameter("keySize"));	   
	  mode = request.getParameter("mode");
		compania = request.getParameter("compania");
	  notasLastLineNo = Integer.parseInt(request.getParameter("notasLastLineNo"));	
	  ArrayList list = new ArrayList();	  
	  String ItemRemoved = "";
		NotasAjustes nAjust = new NotasAjustes();
	  for (int i=0; i<keySize; i++)
	  {
	    NotasAjustesDet nDet = new NotasAjustesDet();


			 nDet.setNotaAjuste(codigo);	
			 nDet.setCompania(request.getParameter("compania"+i));
			 nDet.setSecuencia(request.getParameter("secuencia"+i));
			 nDet.setMonto(request.getParameter("monto"+i));		
			
			 if((request.getParameter("tipo"+i)==null||request.getParameter("tipo"+i).trim().equals(""))&& isAjusteAut.equals("Y"))
			 nDet.setTipo("C");
			 else nDet.setTipo(request.getParameter("tipo"+i));
			 if(request.getParameter("lado_mov"+i)!=null && !request.getParameter("lado_mov"+i).equals("") && request.getParameter("fg")!=null && request.getParameter("fg").equals("AR")) nDet.setLadoMov(request.getParameter("lado_mov"+i));
			 else nDet.setLadoMov(request.getParameter("tipo_docto"));
			 nDet.setDescCentro(request.getParameter("v_codigo"+i));
			 nDet.setDescAjusteDet(request.getParameter("name_code"+i));
			 if(request.getParameter("tipo"+i)!=null && request.getParameter("tipo"+i).equalsIgnoreCase("C"))
					nDet.setCentro(request.getParameter("v_codigo"+i));
			 else if(request.getParameter("tipo"+i)!=null && request.getParameter("tipo"+i).equalsIgnoreCase("E") )
			 {
			 	nDet.setEmpresa(request.getParameter("v_codigo"+i));
				nDet.setCentro("0");
			 }
			 else if(request.getParameter("tipo"+i)!=null && request.getParameter("tipo"+i).equalsIgnoreCase("H") )
			 {
			 	nDet.setMedico(request.getParameter("v_codigo"+i));
				nDet.setCentro("0");
			 }
			 nDet.setDescripcion(request.getParameter("name_code"+i));
			 nDet.setFactura(request.getParameter("factura"+i));
			 nDet.setCodBanco(request.getParameter("cod_banco"+i));
			 nDet.setCuentaBanco(request.getParameter("cuenta_banco"+i));
			 if(request.getParameter("pagado"+i) !=null && request.getParameter("pagado"+i).equalsIgnoreCase("S")) 
			 nDet.setPagado("S");
			 else nDet.setPagado("N");
			 nDet.setMontoSaldo(request.getParameter("monto_saldo"+i));
			 nDet.setUsuarioCreacion(request.getParameter("usuario_creacion"+i));
			 nDet.setUsuarioModificacion((String) session.getAttribute("_userName"));
			 nDet.setFechaCreacion(request.getParameter("fecha_creacion"+i));
			 nDet.setFechaModificacion(cDateTime);
			 nDet.setNumCheque(request.getParameter("num_cheque"+i));
			 //nDet.setPaciente (request.getParameter("paciente"+i));
			 nDet.setAmision(request.getParameter("amision"+i));
			 //nDet.setFechaNacimiento(request.getParameter("fecha_nacimiento"+i));
			 nDet.setClienteEmp(request.getParameter("cliente_emp"+i));
			 nDet.setFarhosp(request.getParameter("farhosp"+i));/////cambiar
			 nDet.setAfecta(request.getParameter("afecta"+i));
			 nDet.setPase(request.getParameter("pase"+i));
			 nDet.setPaseK(request.getParameter("pase_k"+i));
			 nDet.setPuntosSino(request.getParameter("puntos_sino"+i));
			 nDet.setFactClinica(request.getParameter("fact_clinica"+i));
			 //nDet.setPacId(request.getParameter("pac_id"+i));
			 if(request.getParameter("pac_id"+i) != null && !request.getParameter("pac_id"+i).trim().equals(""))nDet.setPacId(request.getParameter("pac_id"+i));
			 else nDet.setPacId(request.getParameter("pac_id"));
			 
			 if(request.getParameter("fecha_nacimiento"+i) != null && !request.getParameter("fecha_nacimiento"+i).trim().equals(""))nDet.setFechaNacimiento(request.getParameter("fecha_nacimiento"+i));
			 else nDet.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
			 if(request.getParameter("paciente"+i) != null && !request.getParameter("paciente"+i).trim().equals(""))nDet.setPaciente(request.getParameter("paciente"+i));
			 else nDet.setPaciente(request.getParameter("codigo_paciente"));
				 
	    key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 		  
		  ItemRemoved = key;		 
		}
		else
		{
	      try{ 
		        iNotas.put(key,nDet);
						nAjust.addNotasDetalle(nDet);
		        list.add(nDet);
		     }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	    }
	  }	//for

	  if (!ItemRemoved.equals(""))
	  {
			 //vFact.remove(((FactoresEval) iFact.get(ItemRemoved)).getFactor());
			 iNotas.remove(ItemRemoved);
			 response.sendRedirect("../facturacion/notas_ajustes_detail.jsp?mode="+mode+"&notasLastLineNo="+notasLastLineNo+"&codigo="+codigo+"&factura="+factura+"&fg="+fg+"&isAjusteAut="+isAjusteAut);
			 return;
	  }

	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {	
			
				NotasAjustesDet naj = new NotasAjustesDet();
				naj.setSecuencia("0");
				naj.setPagado("N");
				naj.setFarhosp("N");
				naj.setUsuarioCreacion((String) session.getAttribute("_userName"));
				naj.setFechaCreacion(cDateTime);
				if(request.getParameter("fg")!=null && request.getParameter("fg").equals("AF") && request.getParameter("factura")!=null)naj.setFactura(request.getParameter("factura"));
				if(request.getParameter("fg")!=null && request.getParameter("fg").equals("AF")) naj.setLadoMov(request.getParameter("tipo_docto"));
				notasLastLineNo++;
				if (notasLastLineNo < 10) key = "00" +notasLastLineNo;
				else if (notasLastLineNo < 100) key = "0" +notasLastLineNo;
				else key = "" +notasLastLineNo;
				naj.setKey(key);
				try
				{
						iNotas.put(key,naj);
				}
				catch(Exception e)
				{
						System.err.println(e.getMessage());
				}
		
		
		 response.sendRedirect("../facturacion/notas_ajustes_detail.jsp?mode="+mode+"&notasLastLineNo="+notasLastLineNo+"&type=1&codigo="+codigo+"&factura="+factura+"&fg="+fg+"&isAjusteAut="+isAjusteAut);
		
		 
		 return;
	  }
		
		 nAjust.setConta(request.getParameter("conta"));
		 nAjust.setCompania((String) session.getAttribute("_companyId"));
		 nAjust.setCodigo(request.getParameter("codigo"));
		 nAjust.setExplicacion(request.getParameter("explicacion"));
		 nAjust.setFecha(request.getParameter("fecha"));
		 nAjust.setUsuarioCreacion(request.getParameter("usuario_creacion"));
		 nAjust.setUsuarioModificacion((String) session.getAttribute("_userName"));
		 nAjust.setFechaCreacion(request.getParameter("fecha_creacion"));
		 nAjust.setFechaModificacion(cDateTime);
		 nAjust.setTipoDoc(request.getParameter("tipo_doc")); 
		 if(request.getParameter("tipo_docto")!=null && !request.getParameter("tipo_docto").equals("")) nAjust.setTipoDocto(request.getParameter("tipo_docto"));
		 nAjust.setFactura(request.getParameter("factura"));
		 nAjust.setTipoAjuste(request.getParameter("tipo_ajuste"));
		 nAjust.setRecibo(request.getParameter("recibo")); 
		 nAjust.setFacturaAplic(request.getParameter("factura_aplic"));
		 nAjust.setTotal(request.getParameter("total"));
		 nAjust.setEstatus(request.getParameter("estatus")); 
		 nAjust.setReferencia(request.getParameter("referencia"));
		 nAjust.setActSn(request.getParameter("act_sn"));
		 if(request.getParameter("credito")!=null && request.getParameter("credito").equalsIgnoreCase("S")) 
			 nAjust.setCtrlAjuste("S");
		 else nAjust.setCtrlAjuste("N");
		 nAjust.setPase(request.getParameter("pase"));
		 nAjust.setPaseK(request.getParameter("pase_k"));
		 nAjust.setRefReversion (request.getParameter("ref_reversion"));
		 nAjust.setProvincia(request.getParameter("provincia"));
		 nAjust.setSigla(request.getParameter("sigla"));
		 nAjust.setTomo(request.getParameter("tomo")); 
		 nAjust.setAsiento(request.getParameter("asiento"));
		 nAjust.setAnioParametro(request.getParameter("anio_parametro"));
		 nAjust.setMesParametro(request.getParameter("mes_parametro"));
		 
		 nAjust.setRefType(request.getParameter("ref_type"));
		 nAjust.setRefId(request.getParameter("ref_id"));

 
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("Guardar"))
	  {	
		 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		 ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg+"&isAjusteAut="+isAjusteAut);
		 System.out.println("::::::::::::::::::::::::::::::::::::::::::::::: POSTING... ");
		 if (mode.equalsIgnoreCase("add"))
		 {	 
			NAMgr.add(nAjust,0);
			codigo = NAMgr.getPkColValue("codigo");
		 }
		 else if (mode.equalsIgnoreCase("edit"))
		 {	  
		  //eval.setCodigo(codigo);	    
			NAMgr.update(nAjust,0);
		 }
		 ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  <%if (NAMgr.getErrCode().equals("1")){%>
  parent.document.form0.errCode.value = '<%=NAMgr.getErrCode()%>';
  parent.document.form0.errMsg.value = '<%=NAMgr.getErrMsg()%>';
  parent.document.form0.codigo.value = '<%=codigo%>';
	parent.document.form0.compania.value = '<%=compania%>';
  parent.document.form0.submit(); 
  <%} else throw new Exception(NAMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
