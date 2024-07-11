<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.Comprobante"%>
<%@ page import="issi.contabilidad.CompDetails"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CompMgr" scope="page" class="issi.contabilidad.ComprobanteMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="iCta" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCta" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CompMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String change = request.getParameter("change");
String usadoPor = request.getParameter("usado_por")==null?"":request.getParameter("usado_por");
int lastLineNo = 0;
boolean viewMode = false;

if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;

if (fg == null) throw new Exception("El Tipo de Comprobante no es válido. Por favor intente nuevamente!");
if (fp == null || fp.trim().equals(""))fp="comp_diario";
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	<%if(!mode.trim().equals("view")){%>parent.form1BlockButtons(false);<%}%>

<%
if (request.getParameter("type") != null)
{
%>
	var anio = parent.document.form1.ea_anio.value;
	abrir_ventana1('../contabilidad/sel_plan_ctas_comp.jsp?mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&p_anio='+anio+'&lastLineNo=<%=lastLineNo%>');
<%
}
%>
	calc(false);
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function calc(showAlert)
{
	if(showAlert==undefined||showAlert==null)showAlert=true;
	var totalDb=0.00,totalCr=0.00;
	var size=parseInt(document.form1.size.value,10);
	var x=0;
	for(i=1;i<=size;i++)
	{
		if(eval('document.form1.action'+i).value!='D'){
			var typeMov=eval('document.form1.tipoMov'+i).value;
			var valor=parseFloat(eval('document.form1.valor'+i).value);
			if(typeMov=='DB')totalDb+=valor;
			else totalCr+=valor;
			if(eval('document.form1.cta1'+i).value=='000'){x++;top.CBMSG.warning('Existen registros con cuentas Incorrectas!. Favor Verifique.');break;return false;}
		}
	}

	parent.document.form1.sumDebito.value=(totalDb).toFixed(2);
	parent.document.form1.sumCredito.value=(totalCr).toFixed(2);
	parent.document.form1.totalDb.value=(totalDb).toFixed(2);
	parent.document.form1.totalCr.value=(totalCr).toFixed(2);
	totalDb=(totalDb).toFixed(2);
	totalCr=(totalCr).toFixed(2);
	if(totalDb!=totalCr)
	{
		if(showAlert)top.CBMSG.warning('El Comprobante no está Balanceado');
		return false;
	}
	else if(totalDb==totalCr&&totalDb==0.00)
	{
		if(showAlert)top.CBMSG.warning('El Balance no puede ser igual a Cero (0)');
		return false;
	}
	//if(x>0){if(showAlert)top.CBMSG.warning('Existen registros con cuentas Incorrectas!. Favor Verifique.');return false;}
	return true;
}

function doSubmit()
{
	var error=0;
	if(parent.form1Validation())
	{
		if(form1Validation())
		{
			document.form1.baction.value 				= parent.document.form1.baction.value;
			document.form1.ea_anio.value 				= parent.document.form1.ea_anio.value;
			document.form1.mes.value						= parent.document.form1.mes.value;
			document.form1.consecutivo.value		= parent.document.form1.consecutivo.value;
			<%if(fg.equals("PLA")){%>
			document.form1.anioPla.value 				= parent.document.form1.ea_anio.value;
			document.form1.consecutivoPla.value		= parent.document.form1.consecutivo.value;
			<%}%>
			document.form1.fecha.value 					= parent.document.form1.fecha.value;
			document.form1.fechaSistema.value		= parent.document.form1.fechaSistema.value;
			document.form1.clase_comprob.value	= parent.document.form1.clase_comprob.value;
			document.form1.status.value					= parent.document.form1.status.value;
			document.form1.descripcion.value		= parent.document.form1.descripcion.value;
			document.form1.tipo.value	= parent.document.form1.tipo.value;
			if(parent.document.form1.reg_type)document.form1.reg_type.value	= parent.document.form1.reg_type.value;
			document.form1.n_doc.value					= parent.document.form1.n_doc.value;
			document.form1.totalDb.value				= parent.document.form1.totalDb.value;
			document.form1.totalCr.value				= parent.document.form1.totalCr.value;
			document.form1.saveOption.value 		= parent.document.form1.saveOption.value;

			if(calc())
			{
				if(document.form1.baction.value=='Guardar')document.form1.submit();
			}
			else error++;
		}
		else error++;
	}
	else error++;

	if(error>0)
	{
		parent.form1BlockButtons(false);
		form1BlockButtons(false);
		return false;
	}
}

function addAccount(objVal)
{
	if(parent.document.form1.ea_anio.value!='')
	{
		setBAction('form1',objVal);
		document.form1.submit();
	}
	else
	{
		top.CBMSG.warning('Por favor introduzca el año!');
		parent.document.form1.ea_anio.focus();
	}
}

function removeItemComp(k)
{
	removeItem('form1',k);
	parent.form1BlockButtons(true);
	form1BlockButtons(true);
	document.form1.submit();
}

function setRef(k)
{
	clearRef(k);
	if(eval('document.form1.refType'+k).value=='1')abrir_ventana1('../common/search_paciente.jsp?fp=asiento&index='+k);
	else if(eval('document.form1.refType'+k).value=='2')abrir_ventana1('../common/search_proveedor.jsp?fp=asiento&index='+k);
	else if(eval('document.form1.refType'+k).value=='3')abrir_ventana1('../common/search_banco.jsp?fp=asiento&index='+k);
}

function clearRef(k)
{
	//eval('document.form1.refId'+k).value='';
	//eval('document.form1.refDesc'+k).value='';
}
function setRefDet(k)
{
 	var lado  = eval('document.form1.tipoMov'+k).value;
	var monto = eval('document.form1.valor'+k).value;
	var anio  = parent.document.form1.ea_anio.value;
	var tipo  = parent.document.form1.tipo.value;
	var no    = parent.document.form1.consecutivo.value;
    var renglon = eval('document.form1.renglon'+k).value;
	var status = parent.document.form1.status.value;
	var estado = parent.document.form1.estado.value;
	var regType = parent.document.form1.reg_type.value;
	var mode ='';
	if(regType =='D'){
	if(status != 'PE'){
	if(status!='AP'||estado!='A') mode='view';
	abrir_ventana1('../contabilidad/reg_auxiliar_det.jsp?fp=asiento&index='+k+'&renglon='+renglon+'&no='+no+'&anio='+anio+'&tipo='+tipo+'&mode='+mode);
	//showPopWin('../contabilidad/reg_auxiliar_det.jsp?fp=asiento&index='+k+'&renglon='+renglon+'&no='+no+'&anio='+anio+'&tipo='+tipo,winWidth*.75,winHeight*.60,null,null,'');
	}else{ top.CBMSG.warning('El comprobante debe estar aprobado para agregar detalle!.');}
	}else top.CBMSG.warning('Solo para Comprobantes Diarios');}

function mayorGeneral(cta1,cta2,cta3,cta4,cta5,cta6,num_cta){closeChild=false;
var anio=parent.document.form1.ea_anio.value;
var mes=parent.document.form1.mes.value;
abrir_ventana('../contabilidad/ver_mayor.jsp?fg=CS&cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta5='+cta5+'&cta6='+cta6+'&num_cta='+num_cta+'&filtrado_por=M&anio='+anio+'&mes='+mes);}
function setCuentas(k){abrir_ventana('../common/search_catalogo_gral.jsp?fp=compPlanilla&index='+k);}

function openAudParams(i){
 var consecutivo = parent.document.getElementById("consecutivo").value || 'ALL';
 var anio = parent.document.getElementById("ea_anio").value || 0;
 var mes = parent.document.getElementById("mes").value || 0;
 var cuenta = document.getElementById("c_cuenta"+i).value || "ALL";
 var clase = parent.document.getElementById("clase_comprob").value || 0;
 var claseText = $("#clase_comprob").selText(parent.document) || "N/A";
 var descCuenta = $("#descCuenta"+i).val() || "N/A";
 
 var cta1 = document.getElementById("cta1"+i).value;
 var cta2 = document.getElementById("cta2"+i).value;
 var cta3 = document.getElementById("cta3"+i).value;
 var cta4 = document.getElementById("cta4"+i).value;
 var cta5 = document.getElementById("cta5"+i).value;
 var cta6 = document.getElementById("cta6"+i).value;
 var ctaCompleta = cta1+"."+cta2+"."+cta3+"."+cta4+"."+cta5+"."+cta6;
 var xtraParams = "?consecutivo="+consecutivo+"&mes="+mes+"&anio="+anio+"&cuenta="+cuenta+"&cta1="+cta1+"&cta2="+cta2+"&cta3="+cta3+"&cta4="+cta4+"&cta5="+cta5+"&cta6="+cta6+"&ctaCompleta="+ctaCompleta+"&clase="+clase+"&claseText="+claseText+"&descCuenta="+descCuenta;

 abrir_ventana('../contabilidad/aud_params.jsp'+xtraParams);
 }
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" align="center">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+iCta.size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>

<%=fb.hidden("ea_anio","")%>
<%=fb.hidden("mes","")%>
<%=fb.hidden("consecutivo","")%>
<%=fb.hidden("fecha","")%>
<%=fb.hidden("fechaSistema","")%>
<%=fb.hidden("clase_comprob","")%>
<%=fb.hidden("status","")%>
<%=fb.hidden("descripcion","")%>
<%=fb.hidden("consecutivoCia","")%>
<%=fb.hidden("n_doc","")%>
<%=fb.hidden("totalDb","")%>
<%=fb.hidden("totalCr","")%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("tipo","")%>
<%=fb.hidden("anioPla","")%>
<%=fb.hidden("consecutivoPla","")%>
<%=fb.hidden("reg_type","")%>
<tr class="TextHeader" align="center">
	<td width="14%">Cuenta</td>
	<td width="19%">Descripcion</td>
	<td width="8%">Tipo de Mov.</td>
	<td width="7%">Valor</td>
	<td width="20%">Comentario</td>
	<td width="7%">Tipo de Referencia</td>
	<!--<td width="7%">Referencia</td>
	<td width="19%">Ref. Descripci&oacute;n</td>-->
	<td width="5%">&nbsp;</td>
	<td width="2%"><%=fb.button("addAcc","+",true,viewMode,null,null,"onClick=\"javascript:addAccount(this.value)\"","Agregar Cuentas")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(iCta);
for (int i=1; i<=iCta.size(); i++)
{
	key = al.get(i - 1).toString();
	CompDetails cta = (CompDetails) iCta.get(key);
	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	String style = (cta.getAction().equalsIgnoreCase("D"))?" style=\"display:none\"":"";
	if(fg.equals("PLA")&& (cta.getCta1().trim().equals("000")||cta.getDescCuenta().trim().equals("-")))color ="TextRowYell";
	else color = "TextRow01";
%>
<%=fb.hidden("key"+i,cta.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("anio"+i,cta.getAnoCta())%>
<%=fb.hidden("renglon"+i,cta.getRenglon())%>
<%=fb.hidden("action"+i,cta.getAction())%>
<%=fb.hidden("cta1"+i,cta.getCta1())%>
<%=fb.hidden("cta2"+i,cta.getCta2())%>
<%=fb.hidden("cta3"+i,cta.getCta3())%>
<%=fb.hidden("cta4"+i,cta.getCta4())%>
<%=fb.hidden("cta5"+i,cta.getCta5())%>
<%=fb.hidden("cta6"+i,cta.getCta6())%>
<%=fb.hidden("refDesc"+i,cta.getRefDesc())%>
<%=fb.hidden("refId"+i,cta.getRefId())%>
<%=fb.hidden("detalleAux"+i,cta.getDetalleAux())%>
<%=fb.hidden("c_cuenta"+i,cta.getCuenta())%>

<tr class="<%=color%>" align="center" <%=style%>>
	<td>
    <%if (usadoPor.equalsIgnoreCase("S")){%>
    <authtype type='50'><a href="javascript:openAudParams(<%=i%>)"><img height="20" width="20" class="ImageBorder" src="../images/iris.png"></a></authtype><%}%>
    <%=fb.textBox("cuenta"+i,cta.getCuenta(),false,false,true,20,"Text10",null,null)%>
	<authtype type='50'><a href="javascript:mayorGeneral('<%=cta.getCta1()%>','<%=cta.getCta2()%>','<%=cta.getCta3()%>','<%=cta.getCta4()%>','<%=cta.getCta5()%>','<%=cta.getCta6()%>','<%=cta.getCuenta()%>')"><img id="imgMayor<%=i%>" height="20" width="20" class="ImageBorder" src="../images/search.gif"></a></authtype>
	</td>
	<td><%=fb.textBox("descCuenta"+i,cta.getDescCuenta(),false,false,true,50,"Text10",null,null)%>
	<%if(fg.equals("PLA")&& (cta.getCta1().trim().equals("000")||cta.getDescCuenta().trim().equals("-"))){%><%=fb.button("btnCtas"+i,"...",true,viewMode,null,null,"onClick=\"javascript:setCuentas("+i+")\"")%><%}%></td>
	<td><%=fb.select("tipoMov"+i,"DB=DEBITO,CR=CREDITO",cta.getTipoMov(),false,viewMode,1,"Text10","","onChange=\"javascript:calc(false)\"")%></td>
	<td><%=fb.decBox("valor"+i,cta.getValor(),false,false,viewMode,8,"Text10",null,"onChange=\"javascript:calc(false)\"")%></td>
	<td><%=fb.textBox("comentario"+i,cta.getComentario(),false,false,viewMode,60,200,"Text10",null,null)%></td>
	<td><%=fb.select("refType"+i,"0=DIARIO,1=CXC,2=CXP",cta.getRefType(),false,viewMode,0,"Text10",null,"onChange=\"javascript:clearRef("+i+")\"")%></td>
	<!--<td><%//=fb.textBox("refId"+i,(cta.getRefId().equals("-"))?"":cta.getRefId(),false,false,true,8,"Text10",null,null)%></td>
	<td>-->
		<%//=fb.textBox("refDesc"+i,(cta.getRefDesc().equals("-"))?"":cta.getRefDesc(),false,false,true,30,"Text10",null,null)%>
		<%//=fb.button("btnRef"+i,"...",true,viewMode,null,null,"onClick=\"javascript:setRef("+i+")\"")%>

	<td><%=fb.button("btnRefDet"+i,"DET. AUXILIAR",true,((mode.trim().equals("add")||!cta.getCreadoPor().equals("RCM")||cta.getRefType().trim().equals("0"))),null,null,"onClick=\"javascript:setRefDet("+i+")\"")%></td>
	<td align="center"><%=fb.button("rem"+i,"X",true,(viewMode ||(!cta.getDetalleAux().trim().equals("")&&!cta.getDetalleAux().trim().equals("0"))),null,null,"onClick=\"javascript:removeItemComp("+i+")\"","Eliminar Cuenta")%></td>
</tr>
<%
}
%>
<%=fb.formEnd(true)%>
</table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));

	Comprobante CompDet = new Comprobante();

	CompDet.setFg(fg);
	CompDet.setEaAno(request.getParameter("ea_anio"));
	CompDet.setMes(request.getParameter("mes"));
	CompDet.setConsecutivo(request.getParameter("consecutivo"));
	CompDet.setFechaCreacion(request.getParameter("fecha"));
	CompDet.setFechaSistema(request.getParameter("fechaSistema"));
	CompDet.setClaseComprob(request.getParameter("clase_comprob"));
	CompDet.setStatus(request.getParameter("status"));
	CompDet.setDescripcion(request.getParameter("descripcion"));
	CompDet.setNDoc(request.getParameter("n_doc"));
	CompDet.setConsecutivoCia(request.getParameter("consecutivoCia"));
	CompDet.setTotalDb(request.getParameter("totalDb"));
	CompDet.setTotalCr(request.getParameter("totalCr"));
	CompDet.setCompania((String) session.getAttribute("_companyId"));
	CompDet.setUsuario((String) session.getAttribute("_userName"));
	CompDet.setTipo(request.getParameter("tipo"));
	CompDet.setRegType(request.getParameter("reg_type"));
System.out.println(" reg type ==="+CompDet.getRegType());

	if(fg.trim().equals("PLA"))
	{
		CompDet.setFg("CD");
		CompDet.setFgOrigen(fg);
		CompDet.setCreadoPor("RP");
		CompDet.setConsecutivoPla(request.getParameter("consecutivoPla"));
		CompDet.setAnioPla(request.getParameter("anioPla"));
	}

	String itemRemoved = "";
	CompDet.getCompDetail().clear();
	iCta.clear();
	for (int i=1; i<=size; i++)
	{
		CompDetails cta = new CompDetails();

		cta.setKey(request.getParameter("key"+i));
		cta.setAnoCta(request.getParameter("ea_anio"));
		cta.setCta1(request.getParameter("cta1"+i));
		cta.setCta2(request.getParameter("cta2"+i));
		cta.setCta3(request.getParameter("cta3"+i));
		cta.setCta4(request.getParameter("cta4"+i));
		cta.setCta5(request.getParameter("cta5"+i));
		cta.setCta6(request.getParameter("cta6"+i));
		cta.setDescripcion(request.getParameter("descripcion"+i));
		cta.setTipoMov(request.getParameter("tipoMov"+i));
		cta.setValor(request.getParameter("valor"+i));
		cta.setComentario(request.getParameter("comentario"+i));
		cta.setRecibeMov(request.getParameter("recibe_mov"+i));
		cta.setRefType(request.getParameter("refType"+i));
		cta.setAction(request.getParameter("action"+i));
		if(request.getParameter("renglon"+i) !=null && !request.getParameter("renglon"+i).trim().equals(""))
		cta.setRenglon(request.getParameter("renglon"+i));
		else  cta.setRenglon("-1");
		cta.setCuenta(request.getParameter("cuenta"+i));
		cta.setDescCuenta(request.getParameter("descCuenta"+i));
		cta.setDetalleAux(request.getParameter("detalleAux"+i));

		if (cta.getRefType().equals("0"))
		{
			cta.setRefId("-");
			cta.setRefDesc("-");
		}
		else
		{
			if(request.getParameter("refId"+i)!=null&&!request.getParameter("refId"+i).trim().equals(""))cta.setRefId(request.getParameter("refId"+i));
			else cta.setRefId("-");
			if(request.getParameter("refDesc"+i)!=null&&!request.getParameter("refDesc"+i).trim().equals(""))cta.setRefDesc(request.getParameter("refDesc"+i));
			else cta.setRefDesc("-");
		}

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cta.getKey();
			if (cta.getAction().equalsIgnoreCase("I")) cta.setAction("X");//if it is not in DB then remove it
			else cta.setAction("D");
		}
		//else
		//{
		if (!cta.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iCta.put(cta.getKey(),cta);
				CompDet.getCompDetail().add(cta);
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}
		//}
	}

	if (!itemRemoved.equals(""))
	{
		//CompDetails cta = (CompDetails) iCta.get(itemRemoved);
		//vCta.remove(cta.getCta1()+"-"+cta.getCta2()+"-"+cta.getCta3()+"-"+cta.getCta4()+"-"+cta.getCta5()+"-"+cta.getCta6());
		//iCta.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&fg="+fg+"&fp="+fp+"&lastLineNo="+lastLineNo);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&fg="+fg+"&fp="+fp+"&lastLineNo="+lastLineNo);
		return;
	}

	if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(mode.trim().equals("add"))CompMgr.add(CompDet);
		else CompMgr.update(CompDet);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (CompMgr.getErrCode().equals("1")){%>
	parent.document.form1.errCode.value = '<%=CompMgr.getErrCode()%>';
	parent.document.form1.errMsg.value = '<%=CompMgr.getErrMsg()%>';
	parent.document.form1.submit();
	<%} else throw new Exception(CompMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>