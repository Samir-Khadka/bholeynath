package com.samirkhadka.bholeynath

import org.junit.Assert.assertEquals
import org.junit.Test

class AttributionTest {
    @Test fun nameAndRepoMatchPermission() {
        assertEquals("Bholeynath for Android", Attribution.APP_NAME)
        assertEquals("https://github.com/Samir-Khadka/bholeynath", Attribution.REPO_URL)
    }
}
