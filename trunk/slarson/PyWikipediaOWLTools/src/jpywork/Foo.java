import org.python.core.*;

public class Foo extends java.util.Date implements org.python.core.PyProxy, org.python.core.ClassDictInit {
    static String[] jpy$mainProperties = new String[] {"python.modules.builtin", "exceptions:org.python.core.exceptions"};
    static String[] jpy$proxyProperties = new String[] {"python.modules.builtin", "exceptions:org.python.core.exceptions", "python.options.showJavaExceptions", "true"};
    static String[] jpy$packages = new String[] {"java.util", null};
    
    public static class _PyInner extends PyFunctionTable implements PyRunnable {
        private static PyObject i$0;
        private static PyObject i$1;
        private static PyObject s$2;
        private static PyObject s$3;
        private static PyObject s$4;
        private static PyObject s$5;
        private static PyFunctionTable funcTable;
        private static PyCode c$0___init__;
        private static PyCode c$1_bar;
        private static PyCode c$2_toString;
        private static PyCode c$3_Foo;
        private static PyCode c$4_main;
        private static void initConstants() {
            i$0 = Py.newInteger(0);
            i$1 = Py.newInteger(1);
            s$2 = Py.newString("Foo[");
            s$3 = Py.newString(" ");
            s$4 = Py.newString("]");
            s$5 = Py.newString("C:\\Documents and Settings\\stephen\\workspace\\PyWikipediaOWLImport\\src\\Foo.py");
            funcTable = new _PyInner();
            c$0___init__ = Py.newCode(1, new String[] {"self"}, "C:\\Documents and Settings\\stephen\\workspace\\PyWikipediaOWLImport\\src\\Foo.py", "__init__", false, false, funcTable, 0, null, null, 0, 17);
            c$1_bar = Py.newCode(2, new String[] {"self", "incr"}, "C:\\Documents and Settings\\stephen\\workspace\\PyWikipediaOWLImport\\src\\Foo.py", "bar", false, false, funcTable, 1, null, null, 0, 17);
            c$2_toString = Py.newCode(1, new String[] {"self", "cnt"}, "C:\\Documents and Settings\\stephen\\workspace\\PyWikipediaOWLImport\\src\\Foo.py", "toString", false, false, funcTable, 2, null, null, 0, 17);
            c$3_Foo = Py.newCode(0, new String[] {}, "C:\\Documents and Settings\\stephen\\workspace\\PyWikipediaOWLImport\\src\\Foo.py", "Foo", false, false, funcTable, 3, null, null, 0, 16);
            c$4_main = Py.newCode(0, new String[] {}, "C:\\Documents and Settings\\stephen\\workspace\\PyWikipediaOWLImport\\src\\Foo.py", "main", false, false, funcTable, 4, null, null, 0, 16);
        }
        
        
        public PyCode getMain() {
            if (c$4_main == null) _PyInner.initConstants();
            return c$4_main;
        }
        
        public PyObject call_function(int index, PyFrame frame) {
            switch (index){
                case 0:
                return _PyInner.__init__$1(frame);
                case 1:
                return _PyInner.bar$2(frame);
                case 2:
                return _PyInner.toString$3(frame);
                case 3:
                return _PyInner.Foo$4(frame);
                case 4:
                return _PyInner.main$5(frame);
                default:
                return null;
            }
        }
        
        private static PyObject __init__$1(PyFrame frame) {
            frame.getlocal(0).__setattr__("count", i$0);
            return Py.None;
        }
        
        private static PyObject bar$2(PyFrame frame) {
            // Temporary Variables
            PyObject t$0$PyObject;
            
            // Code
            t$0$PyObject = frame.getlocal(0);
            t$0$PyObject.__setattr__("count", t$0$PyObject.__getattr__("count").__iadd__(frame.getlocal(1)));
            return Py.None;
        }
        
        private static PyObject toString$3(PyFrame frame) {
            frame.setlocal(1, frame.getlocal(0).invoke("bar"));
            return s$2._add(frame.getglobal("java").__getattr__("util").__getattr__("Date").__getattr__("toString").__call__(frame.getlocal(0)))._add(s$3)._add(frame.getlocal(1).__repr__())._add(s$4);
        }
        
        private static PyObject Foo$4(PyFrame frame) {
            frame.setlocal("__init__", new PyFunction(frame.f_globals, new PyObject[] {}, c$0___init__));
            frame.setlocal("bar", new PyFunction(frame.f_globals, new PyObject[] {i$1}, c$1_bar));
            frame.setlocal("toString", new PyFunction(frame.f_globals, new PyObject[] {}, c$2_toString));
            return frame.getf_locals();
        }
        
        private static PyObject main$5(PyFrame frame) {
            frame.setglobal("__file__", s$5);
            
            frame.setlocal("java", org.python.core.imp.importOne("java", frame));
            frame.setlocal("Foo", Py.makeClass("Foo", new PyObject[] {frame.getname("java").__getattr__("util").__getattr__("Date")}, c$3_Foo, null, Foo.class));
            return Py.None;
        }
        
    }
    public static void moduleDictInit(PyObject dict) {
        dict.__setitem__("__name__", new PyString("Foo"));
        Py.runCode(new _PyInner().getMain(), dict, dict);
    }
    
    public static void main(String[] args) throws java.lang.Exception {
        String[] newargs = new String[args.length+1];
        newargs[0] = "Foo";
        java.lang.System.arraycopy(args, 0, newargs, 1, args.length);
        Py.runMain(Foo._PyInner.class, newargs, Foo.jpy$packages, Foo.jpy$mainProperties, null, new String[] {"Foo"});
    }
    
    public void finalize() throws java.lang.Throwable {
        super.finalize();
    }
    
    public java.lang.String super__toString() {
        return super.toString();
    }
    
    public java.lang.String toString() {
        PyObject inst = Py.jfindattr(this, "toString");
        if (inst != null) return (java.lang.String)Py.tojava(inst._jcall(new Object[] {}), java.lang.String.class);
        else return super.toString();
    }
    
    public Foo(int arg0, int arg1, int arg2, int arg3, int arg4, int arg5) {
        super(arg0, arg1, arg2, arg3, arg4, arg5);
        __initProxy__(new Object[] {Py.newInteger(arg0), Py.newInteger(arg1), Py.newInteger(arg2), Py.newInteger(arg3), Py.newInteger(arg4), Py.newInteger(arg5)});
    }
    
    public Foo(java.lang.String arg0) {
        super(arg0);
        __initProxy__(new Object[] {arg0});
    }
    
    public Foo(int arg0, int arg1, int arg2, int arg3, int arg4) {
        super(arg0, arg1, arg2, arg3, arg4);
        __initProxy__(new Object[] {Py.newInteger(arg0), Py.newInteger(arg1), Py.newInteger(arg2), Py.newInteger(arg3), Py.newInteger(arg4)});
    }
    
    public Foo(int arg0, int arg1, int arg2) {
        super(arg0, arg1, arg2);
        __initProxy__(new Object[] {Py.newInteger(arg0), Py.newInteger(arg1), Py.newInteger(arg2)});
    }
    
    public Foo(long arg0) {
        super(arg0);
        __initProxy__(new Object[] {Py.newInteger(arg0)});
    }
    
    public Foo() {
        super();
        __initProxy__(new Object[] {});
    }
    
    private PyInstance __proxy;
    public void _setPyInstance(PyInstance inst) {
        __proxy = inst;
    }
    
    public PyInstance _getPyInstance() {
        return __proxy;
    }
    
    private PySystemState __sysstate;
    public void _setPySystemState(PySystemState inst) {
        __sysstate = inst;
    }
    
    public PySystemState _getPySystemState() {
        return __sysstate;
    }
    
    public void __initProxy__(Object[] args) {
        Py.initProxy(this, "Foo", "Foo", args, Foo.jpy$packages, Foo.jpy$proxyProperties, null, new String[] {"Foo"});
    }
    
    static public void classDictInit(PyObject dict) {
        dict.__setitem__("__supernames__", Py.java2py(new String[] {"super__toString", "finalize"}));
    }
    
}
