import com.jivesoftware.community.JiveGlobals;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PowerMockIgnore;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;
import org.mockito.*;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

@RunWith(PowerMockRunner.class)
@PrepareForTest({JiveGlobals.class})
@PowerMockIgnore({"org.apache.log4j.*"})
public class ExampleUnitTestCase {

    //@Mock private SomeClass someObject;

    //@InjectMocks private SomeAction someAction = new SomeAction();

    @Before
    public void setup() {
        PowerMockito.mockStatic(JiveGlobals.class);
        when(JiveGlobals.getJiveProperty("foo", "foo_default")).thenReturn("bar");
    }

    @Test
    public void test_plugin_code() {
        assertEquals("Write some tests for your plugin", "some tests", "some tests");
    }

    @After
    public void teardown() {}

}
