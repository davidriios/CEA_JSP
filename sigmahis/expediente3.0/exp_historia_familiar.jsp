<%// @ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.expediente.HistorialFamiliar"%>
<%@ page import="issi.expediente.DetalleHistorialFamiliar"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="histFamMgr" scope="page" class="issi.expediente.HistorialFamiliarMgr" />
<jsp:useBean id="iHistFam" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
histFamMgr.setConnection(ConMgr);

boolean viewMode = false;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
String codigo = request.getParameter("codigo");
String recuperar = request.getParameter("recuperar");
String key = "";

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";

if (from == null) from = "";
if (codigo == null) codigo = "0";
if (recuperar == null) recuperar = "";

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

HistorialFamiliar histFam = new HistorialFamiliar();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;

int prevAdm = Integer.parseInt(noAdmision) - 1;

int totPrevAdm = 0;

CommonDataObject cdo1 = new CommonDataObject();

if (codigo.equals("0")) {
    cdo1 = SQLMgr.getData("select codigo, usuario_recup from tbl_sal_historial_familiar where pac_id = "+pacId+" and admision = "+noAdmision+" order by 1 desc");
    if (cdo1 == null) cdo1 = new CommonDataObject();
    
    if (!cdo1.getColValue("codigo"," ").trim().equals("")) codigo = cdo1.getColValue("codigo","0");
    
    if (cdo1.getColValue("usuario_recup"," ").trim().equals(""))
        totPrevAdm = CmnMgr.getCount("select count(*) from tbl_sal_historial_familiar where pac_id = "+pacId+" and admision = "+prevAdm);
}

if (!codigo.trim().equals("0")) {
    if (!viewMode) modeSec = "edit";
}

ArrayList al = new ArrayList();

if (request.getMethod().equalsIgnoreCase("GET")){
    
    ArrayList alSang = sbb.getBeanList(ConMgr.getConnection(),"select sangre_id as optValueColumn, tipo_sangre as optLabelColumn, tipo_sangre as optTitleColumn from tbl_bds_tipo_sangre order by sangre_id",CommonDataObject.class);
    
    ArrayList alP = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_parentesco where 1 = 1 "+(mode.equalsIgnoreCase("add")?" and estado = 'A' ":"")+" order by orden",CommonDataObject.class);
    
    if(change == null){ 
        iHistFam.clear();
                
        al = sbb.getBeanList(ConMgr.getConnection(),"select a.codigo, a.cod_parentesco codParentesco, a.edad, a.vivo_muerto vivoMuerto, a.cod_grupo_sang codGrupoSang  from tbl_sal_hist_familiar_det a, tbl_sal_parentesco b where a.cod_parentesco = b.codigo and pac_id = "+pacId+" and admision = "+noAdmision+" order by b.orden ", DetalleHistorialFamiliar.class);
        
        for (int i=0; i<al.size(); i++){
			DetalleHistorialFamiliar dhf = (DetalleHistorialFamiliar) al.get(i);

			dhf.setKey(""+i);
			dhf.setAction("U");

			try
			{
				iHistFam.put(dhf.getKey(),dhf);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
        
        if (al.size() == 0){
			DetalleHistorialFamiliar dhf = new DetalleHistorialFamiliar();
            dhf.setVivoMuerto("");

			dhf.setKey(""+iHistFam.size()+1);
			dhf.setAction("I");

			try
			{
				iHistFam.put(dhf.getKey(),dhf);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
    }    
%>
<!DOCTYPE html>
<html lang="en">   
<head>
<meta charset="utf-8">
<title>Expediente Cellbyte</title>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
    document.title = 'Historia Familiar - '+document.title;
    var noNewHeight = true;
    
    $(function(){
        //recuperar
        <%if(recuperar.equalsIgnoreCase("Y")){%>
            $("#baction").val("Guardar");
            $("#form0").submit();
        <%}%>
  
    });
    
    function __recuperar() {
        window.location = '../expediente3.0/exp_historia_familiar.jsp?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&recuperar=Y';
    }
    
    function doPrint(opt) {
      if (opt && opt == 1) {
        abrir_ventana('../expediente3.0/print_historia_familiar.jsp?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>');
      } else {
        abrir_ventana('../expediente3.0/print_historia_familiar.jsp?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&codigo=<%=codigo%>');
      }
    }
</script>
</head>
<body class="body-form">

    <div class="row">
        <div class="table-responsive" data-pattern="priority-columns">
        
            <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
            <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
            <%=fb.formStart(true)%>
            <%=fb.hidden("baction","")%>
            <%=fb.hidden("mode",mode)%>
            <%=fb.hidden("modeSec",modeSec)%>
            <%=fb.hidden("seccion",seccion)%>
            <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
            <%=fb.hidden("dob","")%>
            <%=fb.hidden("codPac","")%>
            <%=fb.hidden("pacId",pacId)%>
            <%=fb.hidden("noAdmision",noAdmision)%>
            <%=fb.hidden("desc",desc)%>
            <%=fb.hidden("codigo",codigo)%>
            <%=fb.hidden("recuperar",recuperar)%>
            
            <div class="headerform">
                <table cellspacing="0" class="table pull-right table-striped table-custom-1">
                    <tr>
                        <td>
                            <button type="button" class="btn btn-inverse btn-sm" onclick="__recuperar()"  <%=!viewMode && totPrevAdm > 0? "":" disabled"%>><b>Recuperar</b></button>
                            <%=fb.button("imprimir","Imprimir",false,false,null,null,"onClick=\"javascript:doPrint()\"")%>
                            
                            <button type="button" class="btn btn-inverse btn-sm" onclick="javascript:doPrint(1)"><i class="fa fa-print fa-lg"></i> Imprimir Todo</button>
                            
                        </td>
                    </tr>
                </table>
            </div>
            
            <table cellspacing="0" class="table table-small-font table-bordered table-striped">
                <thead>
                    <tr class="bg-headtabla">
                        <td style="vertical-align: middle !important; width:55%;">Parentesco</td>
                        <td style="vertical-align: middle !important; width:5%;">Edad</td>
                        <td style="vertical-align: middle !important; width:10%; text-align:center">Vivo</td>
                        <td style="vertical-align: middle !important; width:30%;">Grupo Sanguineo RH</td>
                        <td>
                            <%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:__submitForm(this.form, this.value)\"","Agregar  Parentescos")%>
                        </td>
                    </tr>
                </thead>
                <%
                al = CmnMgr.reverseRecords(iHistFam);
                for (int i = 0; i<iHistFam.size(); i++){
                    key = al.get(i).toString();
                    DetalleHistorialFamiliar dhf = (DetalleHistorialFamiliar) iHistFam.get(key);
                %>
                    <tr>
                        <td>
                            <%=fb.select("cod_parentesco"+i,alP,dhf.getCodParentesco(),false,viewMode,0,"form-control input-sm",null,null,"","S")%>
                        </td>
                        <td>
                            <%=fb.intBox("edad"+i,dhf.getEdad(),false,false,viewMode,5,"form-control input-sm","width:100px",null)%>
                        </td>
                        <td align="center">
                           <%=fb.checkbox("vivo_muerto"+i,"S",(dhf.getVivoMuerto().equalsIgnoreCase("S")),viewMode,"",null,"")%> 
                        </td>
                        <td colspan="2">
                            <%=fb.select("cod_grupo_sang"+i,alSang,dhf.getCodGrupoSang(),false,viewMode,0,"form-control input-sm",null,null,"","S")%>
                        </td>
                    </tr>
                    <%=fb.hidden("action"+i,dhf.getAction())%>
                    <%=fb.hidden("key"+i,dhf.getKey())%>
                    <%=fb.hidden("codigo"+i,dhf.getCodigo())%>
                
                <%}%>
                <tbody>
                </tbody>
            </table>
            
            <div class="footerform">
                <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                    <tr>
                    <td>
                        <%=fb.hidden("saveOption","O")%>        
                        <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                    </td>
                    </tr>
                </table>   
            </div>            
            <%=fb.hidden("total", ""+iHistFam.size())%>    
            <%=fb.formEnd(true)%>
        </div>
    </div>    

</body>
</html>    

<%
} else {
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("total"));
    
    al.clear();
    iHistFam.clear();
    
    histFam = new HistorialFamiliar();
    histFam.setPacId(request.getParameter("pacId"));
    histFam.setAdmision(request.getParameter("noAdmision"));
    
    if (codigo.trim().equals("0")) {
        histFam.setUsuarioCreacion((String)session.getAttribute("_userName"));
    } else {
        histFam.setCodigo(request.getParameter("codigo"));
        histFam.setUsuarioModificacion((String)session.getAttribute("_userName"));
    }
        
    for (int i = 0; i < size; i++){
        DetalleHistorialFamiliar det = new DetalleHistorialFamiliar();
        
        if (request.getParameter("cod_parentesco"+i) != null) {
            det.setCodParentesco(request.getParameter("cod_parentesco"+i));
            det.setEdad(request.getParameter("edad"+i));
            det.setVivoMuerto(request.getParameter("vivo_muerto"+i)!=null?"S":"N");
            det.setCodGrupoSang(request.getParameter("cod_grupo_sang"+i));
            det.setCodigo(request.getParameter("codigo"+i));
            
            det.setAction(request.getParameter("action"+i));
            det.setKey(""+i);
            
            if (!det.getAction().equalsIgnoreCase("X")){
                try{
                    iHistFam.put(det.getKey(),det);
                    histFam.addDetalle(det);
                }
                catch(Exception e) {
                    System.err.println(e.getMessage());
                }
            }
            
        }
    }
    
    if(baction.equals("+")) {
		DetalleHistorialFamiliar det = new DetalleHistorialFamiliar();

		det.setAction("I");
		det.setKey(""+(iHistFam.size()+1));

		try {
			iHistFam.put(det.getKey(),det);
		}
		catch(Exception e) {
			System.err.println(e.getMessage());
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+desc+"&codigo="+codigo);
		return;
	}
    
    if (baction.equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (recuperar.trim().equalsIgnoreCase("Y")){
            histFamMgr.recuperar(pacId,noAdmision,prevAdm, (String)session.getAttribute("_userName"));
            codigo = histFamMgr.getPkColValue("codigo");
        } else {
            if (modeSec.equalsIgnoreCase("add")) {
                histFamMgr.add(histFam);
                codigo = histFamMgr.getPkColValue("codigo");
            } else {
                histFamMgr.update(histFam);
            }
        }
		ConMgr.clearAppCtx(null);
	}
%>

<html>
<head>
<script>
function closeWindow()
{
<%
if (histFamMgr.getErrCode().equals("1"))
{
%>
	alert('<%=histFamMgr.getErrMsg()%>');
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
	parent.doRedirect(0);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&codigo=<%=codigo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%    
}
%>