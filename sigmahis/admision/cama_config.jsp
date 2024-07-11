<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Cama"%>
<%@ page import="issi.admision.Habitacion"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="HabitMgr" scope="page" class="issi.admision.HabitacionMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iCama" scope="session" class="java.util.Hashtable"/>
<%
/**
==================================================================================
sal900291.fmb
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
HabitMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String fromList = (request.getParameter("fromList")==null?"":request.getParameter("fromList"));
String usosAutCamas= "N";
try {usosAutCamas =java.util.ResourceBundle.getBundle("issi").getString("auto.cama.uso");}catch(Exception e){ usosAutCamas = "N";}

if (mode == null) mode = "";

boolean viewMode = mode.trim().equalsIgnoreCase("view");

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Camas - '+document.title;
function addTipo(i){abrir_ventana1('../admision/cama_tipoohab_list.jsp?index='+i);}
function doSubmit()
{
	document.formCama.baction.value=parent.document.form1.baction.value;
    
    if (parent.document.form1.estadoHab && parent.document.form1.estadoHab.value == 'I'){
        for (var i=1; i<=<%=iCama.size()%>;i++){
          var estadoCam = $("#estado"+i).val();
          if (estadoCam == 'U' || estadoCam == 'M') {
            parent.CBMSG.error("No puedes inactivar la habitación ya que tiene cama en uso!");
            parent.form1BlockButtons(false);
            return;
          }
        }
    }
	if(formCamaValidation())
	{
		document.formCama.saveOption.value=parent.document.form1.saveOption.value;
		document.formCama.codigo.value=parent.document.form1.codigo.value;
		document.formCama.descripcion.value=parent.document.form1.descripcion.value;
		document.formCama.estadoHab.value=parent.document.form1.estadoHab.value;
		document.formCama.centroServCode.value=parent.document.form1.centroServCode.value;
		document.formCama.tipoServCode.value=parent.document.form1.tipoServCode.value;
		document.formCama.accesorio.value=parent.document.form1.accesorio.value;
		document.formCama.comments.value=parent.document.form1.comments.value;
		document.formCama.quirofano.value=parent.document.form1.quirofano.value;
		document.formCama.centro_servicio.value=parent.document.form1.centro_servicio.value;
		document.formCama.submit();
	}
	else
	{
		newHeight();
		parent.form1BlockButtons(false);
	}
}
function checkCode(obj,objOld){
var habitacion = parent.document.form1.codigo.value
if(habitacion !=''){
return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_sal_cama','compania=<%=session.getAttribute("_companyId")%> and codigo=\''+obj.value+'\' and habitacion=\''+habitacion+'\'',objOld.value);}}
function validateCode(){for(var i=1;i<<%=iCama.size()%>;i++)for(var j=i+1;j<=<%=iCama.size()%>;j++)if(eval('document.formCama.codigo'+i).value==eval('document.formCama.codigo'+j).value)return false;return true;}
function doAction(){newHeight();}

function cargosAut(cama){
   var cds = parent.document.form1.centroServCode.value;
   avisarCAUT(cama);
   if(cama !="")abrir_ventana("../admision/cargos_aut_config.jsp?hab=<%=code%>&cama="+cama+"&cds="+cds);
}
 $(document).ready(function(){
    jqTooltip();
 });
 
function avisarCAUT(cama){
  var tot =  parseInt(getDBData('<%=request.getContextPath()%>','count(*) tot ','tbl_sal_cargos_automaticos','cama = \''+cama+'\' and habitacion = \'<%=code%>\' and estado=\'A\'',''));

  if (tot > 0) CBMSG.warning("Esta cama tiene configurada "+tot+" cargo"+(tot > 1?"s":"")+" automático"+(tot > 1?"s":""));
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("formCama",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;else{if(!validateCode()){CBMSG.warning('No se permite Código de Cama Duplicados!');error++;}}");%>
<%=fb.formStart(true)%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("size",""+iCama.size())%>
<%=fb.hidden("codigo","")%>
<%=fb.hidden("descripcion","")%>
<%=fb.hidden("estadoHab","")%>
<%=fb.hidden("centroServCode","")%>
<%=fb.hidden("tipoServCode","")%>
<%=fb.hidden("accesorio","")%>
<%=fb.hidden("quirofano","")%>
<%=fb.hidden("comments", "")%>
<%=fb.hidden("centro_servicio","")%>
<%=fb.hidden("fromList",fromList)%>
<tr class="TextHeader" align="center">
	<td width="8%">C&oacute;digo</td>
	<td width="20%">Descripci&oacute;n</td>
	<td width="40%">Tipo Habitaci&oacute;n</td>
	<td width="2%">Ext.</td>
	<td width="13%">Estado</td>
	<td width="5%">Precio</td>
	<td width="9%"><%if(usosAutCamas.trim().equals("S")){%>Cargos AUT<%}%></td>
	<td width="3%">
		<%=fb.submit("addCama","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Camas")%>
	</td>
</tr>
<%
al = CmnMgr.reverseRecords(iCama);
for (int i=1; i<=iCama.size(); i++)
{
	Cama ca = (Cama) iCama.get(al.get(i - 1));
	String style = (ca.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
	String rowStyle = "TextRow01";
	if (!fromList.trim().equals("") && fromList.trim().equals(ca.getCodigo())) rowStyle = "TextRow04"; //
    
    viewMode = (ca.getOther1() != null && Integer.parseInt(ca.getOther1())>0);
	
%>
<%=fb.hidden("key"+i,ca.getKey())%>
<%=fb.hidden("action"+i,ca.getAction())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("codigoOld"+i,ca.getCodigoOld())%>
<%=fb.hidden("other1"+i,ca.getOther1())%>

<tr class="<%=rowStyle%>" align="center"<%=style%>>
	<td><%=fb.textBox("codigo"+i,ca.getCodigo(),true,false,false,8,10,null,null,"onBlur=\"javascript:checkCode(this,document.formCama.codigoOld"+i+")\"")%></td>
	<td><%=fb.textBox("descripcion"+i,ca.getDescripcion(),false,false,viewMode,30,100)%></td>
	<td>
		<%=fb.textBox("tipoHabCode"+i,ca.getTipoHab(),true,false,true,2)%>
		<%=fb.textBox("tipoHab"+i,ca.getTipoName(),false,false,true,30)%>
		<%=fb.select("catHab"+i,"P=PRIVADA,S=SEMI-PRIVADA,E=ECONOMICA,T=SUITE,Q=QUIROFANO,O=OTROS",ca.getCatHab(),false,true,0)%>
		<%=fb.button("btntipo"+i,"...",true,viewMode,null,null,"onClick=\"javascript:addTipo("+i+")\"")%>
	</td>
	<td><%=fb.textBox("extension"+i,ca.getExtension(),false,false,false,5,5)%></td>
	<td><%=fb.select("estado"+i,"M=MANTENIMIENTO,U=EN USO,D=DISPONIBLE,I=INACTIVO,T=TRAMITE",ca.getEstadoCam(),false,viewMode,0)%></td>
	<td><%=fb.textBox("precio"+i,ca.getPrecio(),false,false,true,7)%></td>
	<td><%if(usosAutCamas.trim().equals("S")){%>
	  <% if (ca.getCodigo()!=null && !ca.getCodigo().trim().equals("")){%>
	    <%=fb.button("btnCAut"+i,"...",true,false,null,null,"onClick=\"javascript:cargosAut('"+ca.getCodigo()+"')\"")%>
	  <%}else{%><!--hint hint--left data-hint-->
	    <div class="hint hint--left" data-hint="Copiar cargos automáticos" style="display:block">
		<%=fb.select(ConMgr.getConnection(),"select distinct cama cod, cama display from tbl_sal_cargos_automaticos where habitacion = '"+code+"' order by cama","copyTo"+i,"",false,false,0,null,"width:40px","","","S")%></div>
	  <%}}%>
	</td>
	<td align="center"><%=(ca.getAction().equalsIgnoreCase("I"))?fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Camas"):""%></td>
</tr>
<%
}
%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));

	Habitacion hab = new Habitacion();
	hab.setCodigoOld(code);
	hab.setCompania((String) session.getAttribute("_companyId"));
	if (size == 0 || mode.equalsIgnoreCase("add")) hab.setCodigo(request.getParameter("codigo"));
	else hab.setCodigo(code);
	hab.setDescripcion(request.getParameter("descripcion"));
	hab.setUnidadAdmin(request.getParameter("centroServCode"));
	hab.setTipoServ(request.getParameter("tipoServCode"));
	hab.setAccesorios(request.getParameter("accesorio"));
	hab.setEstadoHab(request.getParameter("estadoHab"));
	
	hab.setQuirofano(request.getParameter("quirofano"));
	hab.setComments(request.getParameter("comments"));
	if(request.getParameter("centro_servicio")!=null && !request.getParameter("centro_servicio").equals("")) hab.setOther2(request.getParameter("centro_servicio"));
	

	String itemRemoved = "";
	iCama.clear();
	for (int i=1; i<=size; i++)
	{
		Cama ca = new Cama();

		ca.setCodigoOld(request.getParameter("codigoOld"+i));
		ca.setCodigo(request.getParameter("codigo"+i));
		ca.setDescripcion(request.getParameter("descripcion"+i));
		ca.setTipoHab(request.getParameter("tipoHabCode"+i));
		ca.setExtension(request.getParameter("extension"+i));
		ca.setTipoName(request.getParameter("tipoHab"+i));
		ca.setCatHab(request.getParameter("catHab"+i));
		ca.setEstadoCam(request.getParameter("estadoHab")!=null&&request.getParameter("estadoHab").equalsIgnoreCase("I")?"I": request.getParameter("estado"+i));
		ca.setPrecio(request.getParameter("precio"+i));
		ca.setOther1(request.getParameter("other1"+i));
		
		if (request.getParameter("copyTo"+i) != null && !request.getParameter("copyTo"+i).equals("") ){
 	       ca.setCopyFromCama(request.getParameter("copyTo"+i));
		   ca.setTipoAction("C1");
		}
		

		ca.setKey(i);
		ca.setAction(request.getParameter("action"+i));
		if (ca.getAction().equalsIgnoreCase("I"))
		{
			ca.setUserCrea(UserDet.getUserName());
			ca.setFechaCrea("sysdate");
		}
		ca.setUserMod(UserDet.getUserName());
		ca.setFechaMod("sysdate");

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = ca.getKey();
			if (ca.getAction().equalsIgnoreCase("I")) ca.setAction("X");//if it is not in DB then remove it
			else ca.setAction("D");
		}

		if (!ca.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iCama.put(ca.getKey(),ca);
				hab.getCamas().add(ca);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}

	if (!itemRemoved.equals(""))
	{
		response.sendRedirect("../admision/cama_config.jsp?mode="+mode+"&code="+code+"&fromList="+request.getParameter("fromList"));
		return;
	}
	else if (baction.equals("+"))
	{
		Cama ca = new Cama();

		ca.setKey(iCama.size() + 1);
		ca.setAction("I");
		ca.setOther1("0");

		try
		{
			iCama.put(ca.getKey(),ca);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect("../admision/cama_config.jsp?mode="+mode+"&code="+code+"&fromList="+request.getParameter("fromList"));
		return;
	}
	else if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		if (mode.equalsIgnoreCase("add"))
		{
			hab.setUserCrea(UserDet.getUserName());
			hab.setFechaCrea("sysdate");
			hab.setUserMod(UserDet.getUserName());
			hab.setFechaMod("sysdate");
			HabitMgr.add(hab);
		}
		else
		{
			hab.setUserMod(UserDet.getUserName());
			hab.setFechaMod("sysdate");
			HabitMgr.update(hab);
		}
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){parent.document.form1.code.value='<%=hab.getCodigo()%>';parent.document.form1.errCode.value='<%=HabitMgr.getErrCode()%>';parent.document.form1.errMsg.value='<%=HabitMgr.getErrMsg()%>';parent.document.form1.errException.value=('<%=HabitMgr.getErrException()%>');parent.document.form1.submit();}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>